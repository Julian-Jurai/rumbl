defmodule RumblWeb.VideoChannel do 
  use RumblWeb, :channel

  alias Rumbl.{Accounts, Multimedia}
  alias RumblWeb.AnnotationView

  #We extract the video ID using pattern matching: "videos:" <> video_id 
  # will match all topics starting with "videos:" and assign the rest of 
  # the topic to the video_id
  
  def join("videos:" <> video_id, params, socket) do 
    send(self(), :after_join)
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations = 
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    response = %{annotations: annotations}
    
    socket = assign(socket, :video_id, video_id)
    
    {:ok, response, socket}
  end

  # https://hexdocs.pm/phoenix/Phoenix.Channel.html#c:handle_in/3

  def handle_in(event, params, socket) do 
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      {:ok, annotation} ->
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          body: annotation.body,
          at: annotation.at,
          user: RumblWeb.UserView.render("user.json", %{user: user})
        })
        {:reply, :okay, socket} 
      {:error, changeset} -> 
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # https://hexdocs.pm/phoenix/Phoenix.Presence.html#c:track/3-example
  def handle_info(:after_join, socket) do 
    push(socket, "presence_state", RumblWeb.Presence.list(socket))
    {:ok, _} = RumblWeb.Presence.track(
      socket, 
      socket.assigns.user_id, 
      %{device: "browser"})
    {:noreply, socket}
  end
end