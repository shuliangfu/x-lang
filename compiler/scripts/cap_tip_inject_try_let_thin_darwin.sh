#!/usr/bin/env bash
# cap_tip_inject_try_let_thin_darwin.sh — note743y.6.23
# Cap tip mega try_let (2744B) busy-loops via glue_expr_block_transparent_value_ref_at
# on struct-lit assign (context/mod.x hang). Cap tip/egg-build thin try_let (NO LEGACY) and
# BRANCH26-reloc-inject into Cap tip T slot (pad with ret). PLATFORM: MACOS.
set -euo pipefail
cd "$(dirname "$0")/.."
CAP="${XLANG_CAP_TIP_L4_CACHE:-}"
if [ -z "$CAP" ]; then
  for c in /tmp/cap_tip_l4_safe_406200eef "$HOME/.cache/xlang_cap_tip_l4" .cap_tip_l4_cache; do
    [ -x "$c/xlang" ] && CAP=$c && break
  done
fi
[ -n "$CAP" ] && [ -x "$CAP/xlang" ] || { echo "need Cap tip cache" >&2; exit 1; }
# HARD (manager 2026-10-24): NEVER product_legacy_bak — Cap tip or pin-egg only.
mkdir -p build_asm/selfhost_pabi
O=build_asm/selfhost_pabi/av_assign_var_try_let.o
SRC=src/runtime_pipeline_abi_assign_var_try_let_thin.x
_compiler=""
# Cap tip (post prior inject) can compile thin; else pin-egg.
if perl -e 'alarm 90; exec @ARGV' -- "$CAP/xlang" -backend asm -c "$SRC" -o "$O" \
    >/tmp/cap_tip_inject_thin.log 2>&1 && [ -s "$O" ]; then
  _compiler="$CAP/xlang"
elif [ -x seeds/bootstrap_xlangc.darwin.arm64 ] && \
     perl -e 'alarm 90; exec @ARGV' -- seeds/bootstrap_xlangc.darwin.arm64 -backend asm -c "$SRC" -o "$O" \
       >/tmp/cap_tip_inject_thin.log 2>&1 && [ -s "$O" ]; then
  _compiler=seeds/bootstrap_xlangc.darwin.arm64
else
  echo "inject: Cap tip/egg cannot compile try_let thin (no LEGACY fallback)" >&2
  exit 1
fi
echo "inject: thin via $_compiler"
nm -gU "$O" | grep -q 'T _glue_emit_assign_var_try_let_elf_c'
python3 - "$CAP" "$O" <<'PY'
import struct,subprocess,sys,os
CAP,OBJ=sys.argv[1],sys.argv[2]
SYM='_glue_emit_assign_var_try_let_elf_c'

def parse_obj(path):
  data=open(path,'rb').read()
  ncmds=struct.unpack_from('<I',data,16)[0]; off=32; text=symtab=None
  for _ in range(ncmds):
    cmd,cmdsize=struct.unpack_from('<II',data,off)
    if cmd==0x19:
      nsects=struct.unpack_from('<I',data,off+64)[0]; soff=off+72
      for i in range(nsects):
        sn,sg=data[soff:soff+16].split(b'\0',1)[0],data[soff+16:soff+32].split(b'\0',1)[0]
        fo,al,reloff,nreloc=struct.unpack_from('<IIII',data,soff+48)
        if sn==b'__text' and sg==b'__TEXT':
          text=dict(fo=fo,size=struct.unpack_from('<Q',data,soff+40)[0],reloff=reloff,nreloc=nreloc)
        soff+=80
    elif cmd==0x2:
      symoff,nsyms,stroff,strsize=struct.unpack_from('<IIII',data,off+8)
      symtab=dict(symoff=symoff,nsyms=nsyms,stroff=stroff)
    off+=cmdsize
  syms=[]
  for i in range(symtab['nsyms']):
    strx,typ,sect,desc,value=struct.unpack_from('<IBBHQ',data,symtab['symoff']+i*16)
    syms.append(data[symtab['stroff']+strx:].split(b'\0',1)[0].decode())
  relocs=[]
  for i in range(text['nreloc']):
    r_addr,r_info=struct.unpack_from('<II',data,text['reloff']+i*8)
    relocs.append((r_addr,r_info&0xffffff,(r_info>>27)&1,(r_info>>28)&0xf))
  return data[text['fo']:text['fo']+text['size']],syms,relocs

def segs(path):
  data=open(path,'rb').read(); ncmds=struct.unpack_from('<I',data,16)[0]; off=32; s=[]
  for _ in range(ncmds):
    cmd,cmdsize=struct.unpack_from('<II',data,off)
    if cmd==0x19:
      vmaddr,vmsize,fileoff,filesize=struct.unpack_from('<QQQQ',data,off+24)
      s.append((vmaddr,vmsize,fileoff))
    off+=cmdsize
  return data,s

def va_off(s,va):
  for vmaddr,vmsize,fileoff in s:
    if vmaddr<=va<vmaddr+vmsize: return fileoff+(va-vmaddr)
  raise KeyError(hex(va))

blob,syms,relocs=parse_obj(OBJ)
for binname in ('xlang','xlang_asm','xlang-c','bootstrap_xlangc'):
  path=f'{CAP}/{binname}'
  if not os.path.exists(path):
    continue
  data,sg=segs(path)
  nm=subprocess.check_output(['nm','-n',path],text=True,errors='replace')
  allT=[]; hit=None
  for line in nm.splitlines():
    p=line.split(None,2)
    if len(p)<3 or p[1] not in ('T','t'): continue
    a=int(p[0],16); allT.append(a)
    if p[2]==SYM and p[1]=='T': hit=a
  allT.sort(); slot=next(x for x in allT if x>hit)-hit
  assert len(blob)<=slot, (len(blob),slot)
  sm={}
  for line in subprocess.check_output(['nm',path],text=True,errors='replace').splitlines():
    p=line.split(None,2)
    if len(p)>=3 and p[1] in ('T','t','S','D','B'): sm[p[2]]=int(p[0],16)
  buf=bytearray(blob)
  for addr,symnum,ext,typ in relocs:
    assert ext and typ==2
    target=sm[syms[symnum]]; pc=hit+addr
    instr=struct.unpack_from('<I',buf,addr)[0]; disp=target-pc; imm=disp//4
    assert disp%4==0 and -(1<<25)<=imm<(1<<25)
    struct.pack_into('<I',buf,addr,(instr&0xFC000000)|(imm&0x03ffffff))
  fo=va_off(sg,hit)
  with open(path,'r+b') as f:
    f.seek(fo); f.write(bytes(buf))
    rem=slot-len(buf)
    if rem: f.write((bytes([0xc0,0x03,0x5f,0xd6])*(rem//4+1))[:rem])
  subprocess.check_call(['codesign','-s','-','-f',path])
  print(f'cap_tip_inject_try_let_thin: {binname} ok thin={len(blob)} slot={slot}')
PY
# also refresh Cap tip pabi leftover so reapply does not restore mega
cp -f "$O" "$CAP/pabi/av_assign_var_try_let.o"
echo "cap_tip_inject_try_let_thin: done cache=$CAP"
