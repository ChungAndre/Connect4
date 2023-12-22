defmodule Puissance4Web.Board do
  use Puissance4Web, :live_view

  def mount(_params, _session, socket) do
    grid =
      for x <- 0..6, y <- 0..5, into: %{} do
        {{x, y}, "blue"}
      end

    Puissance4Web.Endpoint.subscribe("syn")

    socket = assign(socket, :grid, grid)
    socket = assign(socket, :current_player, "red")
    socket = assign(socket, :win, false)
    {:ok, socket}
  end

  def handle_info(
        %{
          event: "update",
          payload: %{n_grid: updated_grid, n_current_player: next_player, n_win: win}
        },
        socket
      ) do
    socket = assign(socket, :grid, updated_grid)
    socket = assign(socket, :current_player, next_player)
    socket = assign(socket, :win, win)
    {:noreply, socket}

    if win do
      {:noreply, push_event(socket, "gameover", %{win: win})}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        %{
          event: "resetting",
          payload: %{n_grid: updated_grid, n_current_player: next_player, n_win: win}
        },
        socket
      ) do
    socket = assign(socket, :grid, updated_grid)
    socket = assign(socket, :current_player, next_player)
    socket = assign(socket, :win, win)
    {:noreply, socket}
  end

  def handle_event("reset", _, socket) do
    grid =
      for x <- 0..6, y <- 0..5, into: %{} do
        {{x, y}, "blue"}
      end

    Puissance4Web.Endpoint.broadcast("syn", "resetting", %{
      n_grid: grid,
      n_current_player: "red",
      n_win: false
    })

    {:noreply, socket}
  end

  @spec handle_event(<<_::48>>, map(), %{
          :assigns => atom() | %{:grid => map(), optional(any()) => any()},
          optional(any()) => any()
        }) :: {:noreply, map()}

  def handle_event("toggle", %{"x" => strX, "y" => strY}, socket) do
    if socket.assigns.win do
      {:noreply, socket}
    else

    grid = socket.assigns.grid
    current_player = socket.assigns.current_player
    grid_x = String.to_integer(strX)
    grid_y = String.to_integer(strY)

    updated_grid =
      if check_possible(grid, grid_x, grid_y) do
          # Replace "red" with the desired color
          Map.put(grid, {grid_x, grid_y}, current_player)
      else
        grid
      end

    # Check for win conditions
    win =
      if win(updated_grid, {grid_x, grid_y}, current_player) do
        true
      else
        false
      end

    next_player =
      case Map.get(updated_grid, {grid_x, grid_y}) do
        "red" -> "yellow"
        "yellow" -> "red"
        "blue" -> current_player
      end

    Puissance4Web.Endpoint.broadcast("syn", "update", %{
      n_grid: updated_grid,
      n_current_player: next_player,
      n_win: win
    })
    {:noreply, socket}
  end
end

  defp check_possible(grid, x, y) do
    cond do
      Map.get(grid, {x, y}) != "blue" -> false
      y == 0 -> true
      Map.get(grid, {x, y - 1}) != "blue" -> true
      true -> false
    end
  end





  defp win(grid, {x, y}, color) do
    check_horizontal(grid, {x, y}, color) ||
      check_vertical(grid, {x, y}, color) ||
      check_diagonal_down(grid, {x, y}, color) ||
      check_diagonal_up(grid, {x, y}, color)
  end

  defp check_horizontal(grid, {x, y}, color) do
    count =
      Enum.reduce_while(0..3, 0, fn i, acc ->
        if Map.get(grid, {x - i, y}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
      end) +
        Enum.reduce_while(1..3, 0, fn i, acc ->
          if Map.get(grid, {x + i, y}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
        end)
    count >= 4
  end

  defp check_vertical(grid, {x, y}, color) do
    count =
      Enum.reduce_while(0..3, 0, fn i, acc ->
        if Map.get(grid, {x, y - i}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
      end)
    count >= 4
  end

  defp check_diagonal_up(grid, {x, y}, color) do
    count =
      Enum.reduce_while(0..3, 0, fn i, acc ->
        if Map.get(grid, {x - i, y + i}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
      end) +
        Enum.reduce_while(1..3, 0, fn i, acc ->
          if Map.get(grid, {x + i, y - i}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
        end)
    count >= 4
  end

  defp check_diagonal_down(grid, {x, y}, color) do
    count =
      Enum.reduce_while(0..3, 0, fn i, acc ->
        if Map.get(grid, {x - i, y - i}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
      end) +
        Enum.reduce_while(1..3, 0, fn i, acc ->
          if Map.get(grid, {x + i, y + i}) == color, do: {:cont, acc + 1}, else: {:halt, acc}
        end)
    count >= 4
  end
end
