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
  typedef class multi_field_post_predict_set_field_value_impl;
  typedef class reg_builder;
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
      reg_with_one_field rg = reg_builder #(reg_with_one_field)::create('h1234_5678);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_prev_reg_value() == 'h1234_5678)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_single_field_and_lsb_gap__returns_val_before_predict)
      reg_with_one_field_and_lsb_gap rg = reg_builder #(reg_with_one_field_and_lsb_gap)::create(
          'h1234_0000);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_prev_reg_value() == 'h1234_0000)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_two_fields__returns_val_before_predict)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h1234_5678);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_prev_reg_value() == 'h1234_5678)
    `SVTEST_END


    `SVTEST(call__reg_with_single_field__called_once)
      reg_with_one_field rg = reg_builder #(reg_with_one_field)::create();
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.num_post_predict_calls == 1)
    `SVTEST_END


    `SVTEST(post_predict__reg_with_two_fields__prev_value_updates)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h1234_5678);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.prev_reg_value_at_post_predict_call == 'h1234_5678)
    `SVTEST_END


    `SVTEST(get_prev_reg_val__reg_with_two_fields__returns_val_for_predict)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h0000_0000);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h1234_5678, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_reg_value() == 'h1234_5678)
    `SVTEST_END


    `SVTEST(get_prev_field_val__reg_with_two_fields__returns_vals_before_predict)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h1234_5678);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_prev_field_value(rg.FIELD0) == 'h5678)
      `FAIL_UNLESS(post_predict.get_prev_field_value(rg.FIELD1) == 'h1234)
    `SVTEST_END


    `SVTEST(get_field_val__reg_with_two_fields__returns_vals_for_predict)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h0000_0000);
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h1234_5678, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(post_predict.get_field_value(rg.FIELD0) == 'h5678)
      `FAIL_UNLESS(post_predict.get_field_value(rg.FIELD1) == 'h1234)
    `SVTEST_END


    `SVTEST(get_kind__reg__returns_kind_for_predict)
      uvm_reg rg = reg_builder #(reg_with_one_field)::create();
      multi_field_post_predict_dummy_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      void'(rg.predict('h0, .kind(UVM_PREDICT_WRITE)));
      `FAIL_UNLESS(post_predict.get_kind() == UVM_PREDICT_WRITE)

      void'(rg.predict('h0, .kind(UVM_PREDICT_READ)));
      `FAIL_UNLESS(post_predict.get_kind() == UVM_PREDICT_READ)
    `SVTEST_END


    `SVTEST(set_field_val__reg_with_two_fields_set_lowest__updates_the_field)
      reg_with_two_fields rg = reg_builder #(reg_with_two_fields)::create('h0000_0000);
      multi_field_post_predict_set_field_value_impl post_predict = new();
      multi_field_post_predict::add(post_predict, rg);

      post_predict.field_to_update = rg.FIELD0;
      void'(rg.predict('h1234_5678, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(rg.FIELD0.get_mirrored_value() == 42)
    `SVTEST_END

  `SVUNIT_TESTS_END


  class multi_field_post_predict_dummy_impl extends multi_field_post_predict;

    int unsigned num_post_predict_calls;
    uvm_reg_data_t prev_reg_value_at_post_predict_call;

    protected virtual function void call();
      num_post_predict_calls++;
      prev_reg_value_at_post_predict_call = get_prev_reg_value();
    endfunction

  endclass


  class multi_field_post_predict_set_field_value_impl extends multi_field_post_predict;

    uvm_reg_field field_to_update;

    protected virtual function void call();
      set_field_value(field_to_update, 42);
    endfunction

  endclass


  class reg_builder #(type T = uvm_reg);

    static function T create(uvm_reg_data_t value = '0);
      dummy_reg_block reg_block = new();
      T rg = new();
      rg.configure(reg_block);
      reg_block.default_map = reg_block.create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
      reg_block.default_map.add_reg(rg, 'h0);
      reg_block.lock_model();
      void'(rg.predict(value));
      return rg;
    endfunction

  endclass


  class dummy_reg_block extends uvm_reg_block;

    local static int unsigned idx;

    function new();
      super.new($sformatf("%s_reg_block_%0d", name, idx));
      idx++;
    endfunction

  endclass


  class reg_with_one_field extends uvm_reg;

    uvm_reg_field FIELD0;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 32, 0, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass


  class reg_with_one_field_and_lsb_gap extends uvm_reg;

    uvm_reg_field FIELD0;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 16, 16, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass


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
