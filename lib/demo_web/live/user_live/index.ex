defmodule DemoWeb.UserLive.Index do
  use Phoenix.LiveView

  alias Demo.Accounts
  alias DemoWeb.UserView
  alias DemoWeb.Router.Helpers, as: Routes

  def render(assigns), do: UserView.render("index.html", assigns)

  def mount(_params, _session, socket) do
    IO.puts("mount: #{inspect(connected?(socket))}")
    {:ok, assign(socket, page: 1, per_page: 5, current_user: nil)}
  end

  def handle_params(params, _url, socket) do
    {page, ""} = Integer.parse(params["page"] || "1")
    IO.puts("handle_params: #{inspect(params)} #{inspect(connected?(socket))}")

    {:noreply,
      socket
      |> assign(page: page)
      |> fetch()
      |> assign_current_user(params)
    }
  end

  defp fetch(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    users = Accounts.list_users(page, per_page)
    assign(socket, users: users, page_title: "Listing Users – Page #{page}")
  end

  defp assign_current_user(%{assigns: %{users: users}} = socket, %{"user" => username} = _params) do
    current_user =
      users
      |> Enum.find(& &1.username == username)

    socket
    |> assign(current_user: current_user)
  end

  defp assign_current_user(socket, _params), do: socket |> assign(:current_user, nil)


  def handle_info({Accounts, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("keydown", %{"code" => "ArrowLeft"}, socket) do
    {:noreply, go_page(socket, socket.assigns.page - 1)}
  end
  def handle_event("keydown", %{"code" => "ArrowRight"}, socket) do
    {:noreply, go_page(socket, socket.assigns.page + 1)}
  end
  def handle_event("keydown", _, socket), do: {:noreply, socket}

  def handle_event("hide_edit_component", params, socket) do
    {:noreply,
      socket
      |> assign_current_user(nil)
      |> push_patch(
        to:
          DemoWeb.Router.Helpers.live_path(
            socket,
            __MODULE__
          ),
        replace: true
      )
    }
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    {:noreply, socket}
  end

  defp go_page(socket, page) when page > 0 do
    push_patch(socket, to: Routes.live_path(socket, __MODULE__, page))
  end
  defp go_page(socket, _page), do: socket
end
