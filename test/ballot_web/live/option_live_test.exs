defmodule BallotWeb.OptionLiveTest do
  use BallotWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ballot.BusinessFixtures

  @create_attrs %{value: "some value"}
  @update_attrs %{value: "some updated value"}
  @invalid_attrs %{value: nil}

  defp create_option(_) do
    option = option_fixture()
    %{option: option}
  end

  describe "Index" do
    setup [:create_option]

    test "lists all options", %{conn: conn, option: option} do
      {:ok, _index_live, html} = live(conn, ~p"/options")

      assert html =~ "Listing Options"
      assert html =~ option.value
    end

    test "saves new option", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/options")

      assert index_live |> element("a", "New Option") |> render_click() =~
               "New Option"

      assert_patch(index_live, ~p"/options/new")

      assert index_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#option-form", option: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/options")

      html = render(index_live)
      assert html =~ "Option created successfully"
      assert html =~ "some value"
    end

    test "updates option in listing", %{conn: conn, option: option} do
      {:ok, index_live, _html} = live(conn, ~p"/options")

      assert index_live |> element("#options-#{option.id} a", "Edit") |> render_click() =~
               "Edit Option"

      assert_patch(index_live, ~p"/options/#{option}/edit")

      assert index_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#option-form", option: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/options")

      html = render(index_live)
      assert html =~ "Option updated successfully"
      assert html =~ "some updated value"
    end

    test "deletes option in listing", %{conn: conn, option: option} do
      {:ok, index_live, _html} = live(conn, ~p"/options")

      assert index_live |> element("#options-#{option.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#options-#{option.id}")
    end
  end

  describe "Show" do
    setup [:create_option]

    test "displays option", %{conn: conn, option: option} do
      {:ok, _show_live, html} = live(conn, ~p"/options/#{option}")

      assert html =~ "Show Option"
      assert html =~ option.value
    end

    test "updates option within modal", %{conn: conn, option: option} do
      {:ok, show_live, _html} = live(conn, ~p"/options/#{option}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Option"

      assert_patch(show_live, ~p"/options/#{option}/show/edit")

      assert show_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#option-form", option: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/options/#{option}")

      html = render(show_live)
      assert html =~ "Option updated successfully"
      assert html =~ "some updated value"
    end
  end
end
