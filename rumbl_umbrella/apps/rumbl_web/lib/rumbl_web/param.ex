
# Overwrites how routes with params are built for the 
# video module. Routes.watch_path(conn, :show, video)
defimpl Phoenix.Param, for: Rumbl.Multimedia.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
