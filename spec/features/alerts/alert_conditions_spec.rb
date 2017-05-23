include RSpec::Expectations
include SessionHelpers
include GenericHelpers

describe "Alert Conditions", :type => :feature do
  include_examples "authenticated"

  before(:all) do
    @alertConditionName = randomName
  end

  before(:each) do
    visit "/alerts"
    click_on "Manage conditions"
  end

  it "create a new field alert condition" do
    click_on "Add new condition"
    fill_typeahead "Alert on stream", with: "All messages"

    expect(page).to have_select("Condition type", with_options: [
      "Field Content Alert Condition",
      "Field Aggregation Alert Condition",
      "Message Count Alert Condition"
    ])
    expect(type_condition_select).to have_placeholder("Select a condition type")
    select "Field Content Alert Condition", from: "Condition type"

    click_on "Add alert condition"

    fill_in id: "title", with: @alertConditionName
    fill_in id: "field", with: "message"
    fill_in id: "value", with: "alerting value"

    click_on "Save"

    expect(alert_condition_entry(@alertConditionName)).to have_text("Alerting on stream All messages")
    expect(alert_condition_entry(@alertConditionName)).to have_text("Alert is triggered when messages matching <message: \"alerting value\"> are received. Grace period: 0 minutes. Not including any messages in alert notification.")
  end

  it "edit an existing field condition and change field" do
    within(alert_condition_entry(@alertConditionName)) do
      click_on @alertConditionName
    end

    within(alert_condition_entry(@alertConditionName)) do
      click_on "Edit"
    end

    fill_in id: "field", with: "source"

    click_on "Save"

    expect(alert_condition_entry(@alertConditionName)).to have_text("Alerting on stream All messages")
    expect(alert_condition_entry(@alertConditionName)).to have_text("Alert is triggered when messages matching <source: \"alerting value\"> are received. Grace period: 0 minutes. Not including any messages in alert notification.")
  end

  it "delete an existing alert condition" do
    within(alert_condition_entry(@alertConditionName)) do
      click_on "Actions"

      accept_alert("Really delete alert condition?") do
        click_on "Delete"
      end
    end

    expect(page).not_to have_text(@alertConditionName)
  end

  def alert_conditions_list
    find("ul.entity-list")
  end

  def alert_condition_entry(alertConditionName)
    alert_conditions_list.find("li", text: alertConditionName)
  end

  def type_condition_select
    find(:select, "Condition type")
  end
end