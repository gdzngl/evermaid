Feature: We can update fields
  As a user of evernote 
  I was to enter natural language dates and have them updated

  Scenario: Update a field
    Given evermaid
    When I successfully run `evermaid.rb --update-times EM-Review`
    Then stdout should contain "in one week"
