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


  local const string name;
  local uvm_reg_field last_field;
  local capture_prev_value_cb capture_cbs[uvm_reg_field];
  local call_post_predict_cb call_cb;


  function new();
    name = $sformatf("%s_%d", get_type_name(), this);
  endfunction


  static function void add(multi_field_post_predict inst, uvm_reg rg);
    uvm_reg_field fields[$];
    rg.get_fields(fields);

    foreach (fields[i]) begin
      capture_prev_value_cb capture_cb = new(inst);
      uvm_reg_field_cb::add(fields[i], capture_cb);
      inst.capture_cbs[fields[i]] = capture_cb;
    end

    // We rely on the fact that 'predict(...)' gets called on the last field after all other fields
    // have already been processed.
    inst.last_field = fields[fields.size()-1];
    inst.call_cb = new(inst);
    uvm_reg_field_cb::add(inst.last_field, inst.call_cb);
  endfunction


  /**
   * Returns the value of the register before the predict call.
   */
  function uvm_reg_data_t get_prev_reg_value();
    uvm_reg_data_t result;
    foreach (capture_cbs[field])
      result |= capture_cbs[field].prev_value << field.get_lsb_pos();
    return result;
  endfunction


  /**
   * Returns the value to be set in the register by the predict call.
   */
  function uvm_reg_data_t get_reg_value();
    uvm_reg_data_t result;
    foreach (capture_cbs[field])
      result |= capture_cbs[field].value << field.get_lsb_pos();
    return result;
  endfunction


  /**
   * Returns the value of the field before the predict call.
   */
  function uvm_reg_data_t get_prev_field_value(uvm_reg_field field);
    return capture_cbs[field].prev_value;
  endfunction


  /**
   * Returns the value to be set in the field by the predict call.
   */
  function uvm_reg_data_t get_field_value(uvm_reg_field field);
    return capture_cbs[field].value;
  endfunction


  /**
   * Sets the specified value in the field during the predict call.
   */
  protected function void set_field_value(uvm_reg_field field, uvm_reg_data_t value);
    void'(field.predict(value));

    // The value of the last field will be overwritten with what UVM computes. This function will be
    // called from a 'post_predict' callback, which will indirectly update the field via the 'value'
    // parameter. It will undo any 'field.predict(...)' calls.
    if (field == last_field)
      call_cb.value_to_set.push_back(value);
  endfunction


  /**
   * Returns the kind of the predict call.
   */
  function uvm_predict_e get_kind();
    uvm_reg_field field;
    void'(capture_cbs.first(field));
    return capture_cbs[field].kind;
  endfunction


  protected pure virtual function void call();


  /* local */ class capture_prev_value_cb extends uvm_reg_cbs;

    uvm_reg_data_t prev_value;
    uvm_reg_data_t value;
    uvm_predict_e kind;

    local const multi_field_post_predict parent;

    function new(multi_field_post_predict parent);
      super.new($sformatf("%s__%s", parent.name, get_type_name()));
    endfunction

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      this.prev_value = previous;
      this.value = value;
      this.kind = kind;
    endfunction

    `m_uvm_get_type_name_func(capture_prev_value_cb)

  endclass


  /* local */ class call_post_predict_cb extends uvm_reg_cbs;

    uvm_reg_data_t value_to_set[$:1];

    local const multi_field_post_predict parent;

    function new(multi_field_post_predict parent);
      super.new($sformatf("%s__%s", parent.name, get_type_name()));
      this.parent = parent;
    endfunction

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      parent.call();
      if (value_to_set.size() > 0)
        value = value_to_set.pop_front();
    endfunction

    `m_uvm_get_type_name_func(call_post_predict_cb)

  endclass


  `m_uvm_get_type_name_func(multi_field_post_predict)

endclass
