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
      date = DateTime.to_date(dt)

      time = DateTime.to_time(dt)

      dif = System.os_time(:second) - (DateTime.from_naive!(@dt, "UTC") |> DateTime.to_unix(:second))

      time_ago(dif, time)
      # transform_date(date) |> transform_time(time, diff) %>
    </time>
    """
  end

  defp transform_date(date) do
    case Date.diff(Date.utc_today(), date) do
      0 ->
        "Danas"

      1 ->
        "Juče"

      2 ->
        "Prekjuče"

      n when n < 11 ->
        "Pre " <> Integer.to_string(n) <> " dana"

      _ ->
        Integer.to_string(date.day) <>
          "." <> Integer.to_string(date.month) <> "." <> Integer.to_string(date.year)
    end
  end

  defp transform_time(date, time, diff) do
    now = Time.utc_now() |> Time.add(diff)

    if date == "Danas" do
      case now |> Time.diff(time, :second) do
        n when n < 60 ->
          "Upravo sada"

        n when n < 1800 ->
          "Pre " <> Integer.to_string(Integer.floor_div(n, 60)) <> " minuta"

        n when n < 2700 ->
          "Pre pola sata"

        n when n < 4500 ->
          "Pre sat vremena"

        n when n < 5400 ->
          "Pre dva sata"

        n when n < 9000 ->
          "Pre tri sata"

        _ ->
          ("Danas u " <> Time.to_string(time))
          |> String.replace(~r/\.[^.]*?$/, "")
          |> String.slice(0..-4)
      end
    else
      (date <> " u " <> Time.to_string(time))
      |> String.replace(~r/\.[^.]*?$/, "")
      |> String.slice(0..-4)
    end
  end

  def time_ago(seconds, time) do
    years = div(seconds, 31_536_000)
    months = div(seconds, 2_592_000)
    days = div(seconds, 864_00)
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
