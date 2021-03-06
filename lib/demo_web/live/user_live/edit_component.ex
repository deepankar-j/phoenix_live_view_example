defmodule DemoWeb.UserLive.EditComponent do
  use Phoenix.LiveComponent

  alias DemoWeb.UserLive
  alias DemoWeb.Router.Helpers, as: Routes
  alias Demo.Accounts

  def mount(socket) do
    {:ok, assign(socket, count: 0)}
  end

  def update(%{user: user} = assigns, socket) do
    IO.puts("update")
    {:ok,
      socket
      |> assign(assigns)
      |> assign(changeset: Accounts.change_user(user))
    }
  end

  def render(assigns), do: DemoWeb.UserView.render("edit.html", assigns)

  def handle_event("validate", %{"user" => params} = p, socket) do
    IO.puts("validate: #{inspect(p)}")
    changeset =
      socket.assigns.user
      |> Demo.Accounts.change_user(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully.")
         |> redirect(to: Routes.live_path(socket, UserLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
