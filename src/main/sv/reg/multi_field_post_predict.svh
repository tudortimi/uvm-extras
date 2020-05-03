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


  local capture_prev_value_cb capture_cbs[$];


  static function void add(multi_field_post_predict inst, uvm_reg rg);
    call_post_predict_cb call_cb = new();
    uvm_reg_field fields[$];
    rg.get_fields(fields);

    foreach (fields[i]) begin
      capture_prev_value_cb capture_cb = new();
      uvm_reg_field_cb::add(fields[i], capture_cb);
      inst.capture_cbs.push_back(capture_cb);
    end

    // We rely on the fact that 'predict(...)' gets called on the last field after all other fields
    // have already been processed.
    call_cb.parent = inst;
    uvm_reg_field_cb::add(fields[fields.size()-1], call_cb);
  endfunction


  /**
   * Returns the value of the register before the predict call.
   */
  function uvm_reg_data_t get_prev_reg_value();
    uvm_reg_data_t result;
    foreach (capture_cbs[i])
      result |= capture_cbs[i].prev_value << capture_cbs[i].lsb_pos;
    return result;
  endfunction


  /**
   * Returns the value to be set in the register by the predict call.
   */
  function uvm_reg_data_t get_reg_value();
    uvm_reg_data_t result;
    foreach (capture_cbs[i])
      result |= capture_cbs[i].value << capture_cbs[i].lsb_pos;
    return result;
  endfunction


  pure virtual function void post_predict();


  class capture_prev_value_cb extends uvm_reg_cbs;

    uvm_reg_data_t prev_value;
    uvm_reg_data_t value;
    int unsigned lsb_pos;

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      this.prev_value = previous;
      this.value = value;
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
