// Copyright 2020 Tudor Timisescu (verificationgentleman.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


virtual class multi_field_post_predict;

  typedef class capture_prev_value_cb;
  typedef class call_post_predict_cb;


  local capture_prev_value_cb capture_cb;


  static function void add(multi_field_post_predict inst, uvm_reg rg);
    capture_prev_value_cb capture_cb = new();
    call_post_predict_cb call_cb = new();
    uvm_reg_field fields[$];
    rg.get_fields(fields);

    uvm_reg_field_cb::add(fields[0], capture_cb);
    inst.set_capture_cb(capture_cb);

    call_cb.parent = inst;
    uvm_reg_field_cb::add(fields[0], call_cb);
  endfunction


  local function void set_capture_cb(capture_prev_value_cb cb);
    capture_cb = cb;
  endfunction


  /**
   * Returns the value of the register before the predict call.
   */
  function uvm_reg_data_t get_prev_reg_value();
    return capture_cb.prev_value << capture_cb.lsb_pos;
  endfunction


  pure virtual function void post_predict();


  class capture_prev_value_cb extends uvm_reg_cbs;

    uvm_reg_data_t prev_value;
    int unsigned lsb_pos;

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      this.prev_value = previous;
      this.lsb_pos = fld.get_lsb_pos();
    endfunction

  endclass


  class call_post_predict_cb extends uvm_reg_cbs;

    multi_field_post_predict parent;

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      parent.post_predict();
    endfunction

  endclass

endclass
