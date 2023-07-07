defmodule Gandalf.ProfileTest do
  use ExUnit.Case, async: false
  alias Gandalf.Profile

  @test_profile "developer_user"

  describe "all_profiles/0" do
    test "returns a list of all profiles" do
      assert Profile.all_profiles() == [@test_profile]
    end
  end

  describe "included_topics/1" do
    test "returns the included topics for a given profile" do
      assert Profile.included_topics!(@test_profile) == [
               "databases",
               "networks",
               "data_structures"
             ]
    end

    test "throws an error if no topic found" do
      assert_raise FunctionClauseError, fn -> Profile.included_topics!("invalid_profile") end
    end
  end
end
