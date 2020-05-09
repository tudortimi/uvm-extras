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


module uvm_reg_acceptance_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "uvm_reg_acceptance_ut";
  svunit_testcase svunit_ut;


  import uvm_pkg::*;

  typedef class capture_cb;
  typedef class reg_builder;
  typedef class dummy_reg_block;
  typedef class reg_with_three_fields;


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

    `SVTEST(uvm_reg__predict__calls_predict_on_last_field_after_all_other_fields)
      reg_with_three_fields rg = reg_builder #(reg_with_three_fields)::create();
      uvm_queue #(uvm_reg_field) queue = new();
      capture_cb cb = new(queue);
      uvm_reg_field_cb::add(rg.FIELD0, cb);
      uvm_reg_field_cb::add(rg.FIELD1, cb);
      uvm_reg_field_cb::add(rg.FIELD2, cb);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_WRITE)));

      `FAIL_UNLESS(queue.size() == 3)

      // The last field is the last element in the array 'returned" by 'uvm_reg::get_fields'. UVM
      // assures us that the topmost field is the last field.
      `FAIL_UNLESS(queue.get(2) == rg.FIELD2)
    `SVTEST_END


    `SVTEST(uvm_reg__predict_direct__does_not_call_post_predict)
      reg_with_three_fields rg = reg_builder #(reg_with_three_fields)::create();
      uvm_queue #(uvm_reg_field) queue = new();
      capture_cb cb = new(queue);
      uvm_reg_field_cb::add(rg.FIELD0, cb);
      uvm_reg_field_cb::add(rg.FIELD1, cb);
      uvm_reg_field_cb::add(rg.FIELD2, cb);

      void'(rg.predict('h0000_0000, .kind(UVM_PREDICT_DIRECT)));

      `FAIL_UNLESS(queue.size() == 0)
    `SVTEST_END

  `SVUNIT_TESTS_END


  class capture_cb extends uvm_reg_cbs;

    local const uvm_queue #(uvm_reg_field) queue;

    function new(uvm_queue #(uvm_reg_field) queue);
      this.queue = queue;
    endfunction

    virtual function void post_predict(
        input uvm_reg_field fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e kind,
        input uvm_path_e path,
        input uvm_reg_map map);
      queue.push_back(fld);
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


  class reg_with_three_fields extends uvm_reg;

    uvm_reg_field FIELD0;
    uvm_reg_field FIELD1;
    uvm_reg_field FIELD2;

    function new(string name = get_type_name());
      super.new(name, 32, 0);
      FIELD0 = uvm_reg_field::type_id::create("FIELD0");
      FIELD0.configure(this, 8, 0, "RW", 0, 0, 1, 1, 0);
      FIELD1 = uvm_reg_field::type_id::create("FIELD1");
      FIELD1.configure(this, 8, 8, "RW", 0, 0, 1, 1, 0);
      FIELD2 = uvm_reg_field::type_id::create("FIELD2");
      FIELD2.configure(this, 8, 16, "RW", 0, 0, 1, 1, 0);
    endfunction

  endclass

endmodule
