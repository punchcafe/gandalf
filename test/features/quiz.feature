Feature: Take Quiz
  Coffee should not be served until paid for
  Coffee should not be served until the button has been pressed
  If there is no coffee left then money should be refunded

  Scenario: Fail topic
    Given failure threshold is 0.6, questions per topic is 3, and max reccomendations is 1
    And I have answered 2 incorrectly
    When I answer incorrectly
    Then The test should be over
    And I should be suggested networks