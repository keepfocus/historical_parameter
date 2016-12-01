# coding: utf-8
require 'test_helper'

class HistoricalEditFormTest < ActiveSupport::TestCase
  include ActionDispatch::Assertions

  def setup
    I18n.reload!
    @template = ActionView::Base.new
    @template.output_buffer = ""
    stub(@template).url_for { "" }
    stub(@template).installation_path { "" }
    stub(@template).installations_path { "" }
    stub(@template).protect_against_forgery? { false }
  end

  test "historical_form_for creates form" do
    output = @template.historical_form_for(Installation.new) {}
    assert_match /<form[^>]*>.*<\/form>/, output
  end

  test "historical_form_for appends content to end of nested form" do
    @template.after_historical_form { "123" }
    @template.after_historical_form { "456" }
    output = @template.historical_form_for(Installation.new) {}
    assert output.include? "123456"
  end

  test "after_historical_form content comes after form" do
    @template.after_historical_form { @template.content_tag :span, "1", :id => "before" }
    output = @template.historical_form_for(Installation.new) {
      @template.after_historical_form { @template.content_tag :span, "1", :id => "inside" }
    }
    assert_select_string output, "form ~ span#before"
    assert_select_string output, "form ~ span#inside"
    assert_select_string output, "form span#before", false
    assert_select_string output, "form span#inside", false
  end

  test "historical_value_fields inserts fields required for a value" do
    value = HistoricalParameter::HistoricalParameter.new
    output = @template.fields_for 'area_history', value, :builder => HistoricalParameter::HistoricalFormBuilder do |b|
      @template.concat b.historical_value_fields
    end
    assert_select_string output, "input[name=?][type=text]", "area_history[value]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(1i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(2i)]"
    assert_select_string output, "select[name=?]", "area_history[valid_from(3i)]"
    assert_select_string output, "input[name=?][type=checkbox]", "area_history[_destroy]"
  end

  test "new_history_value_button is inserted into form and template outside" do
    output = @template.historical_form_for(Installation.new) { |f|
      f.new_history_value_button :area
    }
    assert_select_string output, "form.new_installation" do
      assert_select "input.add_historical_value[type=submit][name=add_area_history_value][data-association=area_history]"
      assert_select "input[name=?]", "installation[area_history_attribute][new_area_history][value]", false
    end
    assert_select_string output, "table#area_history_fields_template" do
      assert_select "tbody tr td input[name=?]", "installation[area_history_attributes][new_area_history][value]", 1
      assert_select "tbody tr td select[name=?]", "installation[area_history_attributes][new_area_history][valid_from(1i)]", 1
      assert_select "tbody tr td select[name=?]", "installation[area_history_attributes][new_area_history][valid_from(2i)]", 1
      assert_select "tbody tr td select[name=?]", "installation[area_history_attributes][new_area_history][valid_from(3i)]", 1
      assert_select "tbody tr td input[name=?][type=checkbox]", "installation[area_history_attributes][new_area_history][_destroy]", 1
    end
  end

  test "history_edit_table_for should create table for editing values over time" do
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr", 2
      assert_select "tr > th", "Value"
      assert_select "tr th", "Valid from"
      assert_select "tr td input[name=?]", "installation[area_history_attributes][0][value]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(4i)]", false
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(5i)]", false
      assert_select "tr td.destroy_historical_value" do
        assert_select "input[name=?][type=checkbox]", "installation[area_history_attributes][0][_destroy]", 1
      end
    end
  end

  test "history_edit_table_for should allow time edit if requested" do
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area, :show_time => true
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr td input[name=?]", "installation[area_history_attributes][0][value]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(4i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(5i)]", 1
    end
  end

  test "history_edit_table_for should also work for saved and reloaded instance" do
    di = Installation.new
    di.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 1, 1)
    di.area_history.build :value => 43, :valid_from => Time.zone.local(2010, 8, 1)
    di.save!
    installation = Installation.find(di.to_param)
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr", 3
      assert_select "tr > th", "Value"
      assert_select "tr th", "Valid from"
      assert_select "tr td input[name=?]", "installation[area_history_attributes][0][value]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][0][valid_from(3i)]", 1
      assert_select "tr td input[name=?][type=checkbox]", "installation[area_history_attributes][0][_destroy]", 1
      assert_select "tr td input[name=?]", "installation[area_history_attributes][1][value]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][1][valid_from(1i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][1][valid_from(2i)]", 1
      assert_select "tr td select[name=?]", "installation[area_history_attributes][1][valid_from(3i)]", 1
      assert_select "tr td input[name=?][type=checkbox]", "installation[area_history_attributes][1][_destroy]", 1
    end
  end

  test "new_history_value_button uses default if no translation present" do
    output = @template.historical_form_for(Installation.new) { |f|
      f.new_history_value_button :area
    }
    assert_select_string output, "form.new_installation" do
      assert_select "input.add_historical_value[value=?]", "Add value"
    end
  end

  test "new_history_value_button is translated" do
    I18n.backend.store_translations :en, :acts_as_historical_parameter => {:new_history_value => "Ny værdi"}
    output = @template.historical_form_for(Installation.new) { |f|
      f.new_history_value_button :area
    }
    assert_select_string output, "form.new_installation" do
      assert_select "input.add_historical_value[value=?]", "Ny værdi"
    end
  end

  test "new_history_value_button can have forced label" do
    output = @template.historical_form_for(Installation.new) { |f|
      f.new_history_value_button :area, :add_label => "Ny areal værdi"
    }
    assert_select_string output, "form.new_installation" do
      assert_select "input.add_historical_value[value=?]", "Ny areal værdi"
    end
  end

  test "history_edit_table_for should have default remove label if no translation present" do
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr td.destroy_historical_value" do
        assert_select "label[for=?]", "installation_area_history_attributes_0__destroy", :text => "Remove?"
      end
    end
  end

  test "history_edit_table_for should translate remove label" do
    I18n.backend.store_translations :en, :acts_as_historical_parameter => {:destroy_label => "Slet værdi"}
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr td.destroy_historical_value" do
        assert_select "label[for=?]", "installation_area_history_attributes_0__destroy", :text => "Slet værdi"
      end
    end
  end

  test "history_edit_table_for should support forced remove label" do
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area, :remove_label => "Slet areal værdi"
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr td.destroy_historical_value" do
        assert_select "label[for=?]", "installation_area_history_attributes_0__destroy", :text => "Slet areal værdi"
      end
    end
  end

  test "history_edit_table_for should translate headings in table" do
    I18n.backend.store_translations :en, :acts_as_historical_parameter => {:value => "Værdi"}
    I18n.backend.store_translations :en, :acts_as_historical_parameter => {:valid_from => "Gælder fra"}
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr", 2
      assert_select "tr > th", "Værdi"
      assert_select "tr th", "Gælder fra"
    end
  end

  test "history_edit_table_for should support forced headings in table" do
    installation = Installation.new
    installation.area_history.build :value => 42, :valid_from => Time.zone.local(2010, 8, 1)
    installation.save
    output = @template.historical_form_for(installation) { |f|
      f.history_edit_table_for :area, :value_heading => "Areal", :valid_from_heading => "Gælder fra"
    }
    assert_select_string output, "table#area_history_table > tbody" do
      assert_select "tr", 2
      assert_select "tr > th", "Areal"
      assert_select "tr th", "Gælder fra"
    end
  end

end
