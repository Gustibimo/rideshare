defmodule RidexWeb.CellChannel do
  use RidexWeb, :channel


  intercept ["ride:requested"]

  def join("user:" <> user_id, _params, socket) do
    %{id: id} = socket.assigns[:current_user]

    if id == user_id,
       do: {:ok, socket},
       else: {:error, :unauthorized}
  end

  def handle_in("ride:request_accepted", %{"request_id" => request_id}, socket) do
    case Ridex.Repo.get(Ridex.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}
      request ->
        case Ridex.Ride.create(request.rider_id, socket.assigns[:current_user].id, request.position) do
          {:ok, ride} ->
            RidexWeb.Endpoint.broadcast("user:#{ride.driver_id}", "ride:created", %{ride_id: ride.id})
            RidexWeb.Endpoint.broadcast("user:#{ride.rider_id}", "ride:created", %{ride_id: ride.id})
            {:reply, :ok, socket}
          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end

  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end

end