defmodule VejperWeb.HtmlHelpers do
  def humanize_datetime(datetime) do
    c = datetime |> DateTime.from_naive!("Europe/Belgrade")

    c = DateTime.add(c, c.std_offset)
    c = DateTime.add(c, c.utc_offset)

    d = DateTime.to_date(c)
    t = DateTime.to_time(c)

    "#{d.day}.#{d.month}.#{d.year} u #{t.hour} i " <>
      if t.minute != 0, do: Integer.to_string(t.minute), else: "00"
  end
end
