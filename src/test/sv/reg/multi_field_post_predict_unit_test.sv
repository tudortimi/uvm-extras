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


module multi_field_post_predict_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "multi_field_post_predict_ut";
  svunit_testcase svunit_ut;


  import uvm_pkg::*;
  import uvm_extras::*;

  typedef class multi_field_post_predict_dummy_impl;
  typedef class dummy_reg_block;
  typedef class reg_with_one_field;
  typedef class reg_with_one_field_and_lsb_gap;
  typedef class reg_with_two_fields;


  function void build();
    svunit_ut = new(name);
  endfunction


  task setup();
    svunit_ut.setup();
  endtask


  task teardown();
    svunit_ut.teardown();
  endtask


  `SVUNIT_TESTS_BEGIN

    `SVTEST(get_prev_reg_val__reg_with_single_field__returns_val_before_predict)
      reg_with_one_field rg = get_new_reg_with_one_field();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h1234_5678));

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.get_prev_reg_value() == 'h1234_5678)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_single_field_and_lsb_gap__returns_val_before_predict)
      reg_with_one_field_and_lsb_gap rg = get_new_reg_with_one_field_and_lsb_gap();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h1234_0000));

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.get_prev_reg_value() == 'h1234_0000)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_two_fields__returns_val_before_predict)
      reg_with_two_fields rg = get_new_reg_with_two_fields();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h1234_5678));

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.get_prev_reg_value() == 'h1234_5678)
    `SVTEST_END


    `SVTEST(post_predict__reg_with_single_field__called_once)
      reg_with_one_field rg = get_new_reg_with_one_field();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.num_post_predict_calls == 1)
    `SVTEST_END


    `SVTEST(post_predict__reg_with_two_fields__prev_value_updates)
      reg_with_two_fields rg = get_new_reg_with_two_fields();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h1234_5678));

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.prev_reg_value_at_post_predict_call == 'h1234_5678)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_two_fields__returns_val_for_predict)
      reg_with_two_fields rg = get_new_reg_with_two_fields();
      multi_field_post_predict_dummy_impl cb = new();
      multi_field_post_predict::add(cb, rg);

      void'(rg.predict('h0000_0000));

      void'(rg.predict('h1234_5678, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(cb.get_reg_value() == 'h1234_5678)
    `SVTEST_END

  `SVUNIT_TESTS_END


  class multi_field_post_predict_dummy_impl extends multi_field_post_predict;

    int unsigned num_post_predict_calls;
    uvm_reg_data_t prev_reg_value_at_post_predict_call;

    virtual function void post_predict();
      num_post_predict_calls++;
      prev_reg_value_at_post_predict_call = get_prev_reg_value();
    endfunction

  endclass


  class dummy_reg_block extends uvm_reg_block;
  endclass


  function automatic reg_with_one_field get_new_reg_with_one_field();
    dummy_reg_block reg_block = new();
    reg_with_one_field rg = new();
    rg.configure(reg_block);
    reg_block.default_map = reg_block.create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
    reg_block.default_map.add_reg(rg, 'h0);
    reg_block.lock_model();
    return rg;
  endfunction


  class reg_with_one_field extends uvm_reg;

    uvm_reg_field FIELD0;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 32, 0, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass


  function automatic reg_with_one_field_and_lsb_gap get_new_reg_with_one_field_and_lsb_gap();
    dummy_reg_block reg_block = new();
    reg_with_one_field_and_lsb_gap rg = new();
    rg.configure(reg_block);
    reg_block.default_map = reg_block.create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
    reg_block.default_map.add_reg(rg, 'h0);
    reg_block.lock_model();
    return rg;
  endfunction


  class reg_with_one_field_and_lsb_gap extends uvm_reg;

    uvm_reg_field FIELD0;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 16, 16, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass


  function automatic reg_with_two_fields get_new_reg_with_two_fields();
    dummy_reg_block reg_block = new();
    reg_with_two_fields rg = new();
    rg.configure(reg_block);
    reg_block.default_map = reg_block.create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
    reg_block.default_map.add_reg(rg, 'h0);
    reg_block.lock_model();
    return rg;
  endfunction


  class reg_with_two_fields extends uvm_reg;

    uvm_reg_field FIELD0;
    uvm_reg_field FIELD1;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 16, 0, "RW", 0, 0, 1, 1, 0);
      FIELD1 = uvm_reg_field::type_id::create("FIELD1");
      FIELD1.configure(this, 16, 16, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass

endmodule
