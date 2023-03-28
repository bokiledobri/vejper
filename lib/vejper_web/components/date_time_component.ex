defmodule VejperWeb.DateTimeComponent do
  use Phoenix.Component
  attr :dt, :any, required: true
  attr :class, :string, default: "self-end italic text-[0.7rem]"
  attr :id, :integer, required: true

  def datetime(assigns) do
    ~H"""
    <time
      id={"time-#{@id}"}
      class={@class}
      tim={DateTime.from_naive!(@dt, "UTC") |> DateTime.to_iso8601()}
      phx-hook="DateTime"
    >
      <%= dt = DateTime.from_naive!(@dt, "Europe/Belgrade")
      diff = dt.utc_offset + dt.std_offset
      dt = DateTime.add(dt, diff)

      time = DateTime.to_time(dt)

      dif = System.os_time(:second) - (DateTime.from_naive!(@dt, "UTC") |> DateTime.to_unix(:second))

      time_ago(dif, time) %>
    </time>
    """
  end

  def time_ago(seconds, time) do
    years = div(seconds, 31_536_000)
    months = div(seconds, 2_592_000)
    days = div(seconds, 86_400)
    hours = div(seconds, 3600)
    minutes = div(seconds, 60)

    at =
      (" u " <> Time.to_string(time))
      |> String.replace(~r/\.[^.]*?$/, "")
      |> String.slice(0..-4)

    cond do
      years > 4 ->
        "pre #{years} godina"

      years > 1 ->
        "pre #{years} godine"

      years > 0 ->
        "pre godinu dana"

      months > 4 ->
        "pre #{months} meseci"

      months > 1 ->
        "pre #{months} meseca"

      months > 0 ->
        "pre mesec dana"

      days == 21 ->
        "pre 21 dan#{at}"

      days > 3 ->
        "pre #{days} dana#{at}"

      days == 2 ->
        "prekjuče#{at}"

      days == 1 ->
        "juče#{at}"

      hours > 21 ->
        "pre #{hours} sata"

      hours == 21 ->
        "pre 21 sat"

      hours > 4 ->
        "pre #{hours} sati"

      hours > 1 ->
        "pre #{hours} sata"

      minutes > 45 ->
        "pre sat vremena"

      minutes > 30 ->
        "pre pola sata"

      minutes > 1 ->
        "pre #{minutes} minuta"

      minutes == 1 ->
        "pre minut"

      true ->
        "upravo sada"
    end
  end
end
