// UEFI application skeleton — PE32+ EFI format with efi_main entry point.
// EFI_SYSTEM_TABLE protocol headers for UEFI app development.

#[repr(C)]
struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
  reset: u64;
  output_string: u64;
  test_string: u64;
  query_mode: u64;
  set_mode: u64;
  set_attribute: u64;
  clear_screen: u64;
  set_cursor_position: u64;
  enable_cursor: u64;
  mode: u64;
}

#[repr(C)]
struct EFI_SYSTEM_TABLE {
  hdr: u64;
  firmware_vendor: u64;
  firmware_revision: u32;
  console_in_handle: u64;
  con_in: u64;
  console_out_handle: u64;
  con_out: u64;
  standard_error_handle: u64;
  std_err: u64;
  runtime_services: u64;
  boot_services: u64;
  number_of_table_entries: u64;
  configuration_table: u64;
}

// efi_main: UEFI entry point — EFI_HANDLE image_handle, EFI_SYSTEM_TABLE *system_table
// Returns EFI_STATUS (u64): 0 = EFI_SUCCESS
#[used]
#[no_mangle]
function efi_main(image_handle: u64, system_table: u64): u64 {
  // In a real UEFI app: call system_table->con_out->output_string(L"Hello UEFI!")
  // For skeleton: just return EFI_SUCCESS
  return 0;
}
