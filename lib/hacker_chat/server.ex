defmodule HackerChat.Server do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: HackerChat.TaskSupervisor]]),
      worker(Task, [HackerChat.Server, :accept, [4040]]),
      #worker(Task, [Server, :broadcaster, [4040]], name: HackerChat.Broadcaster)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def accept(port) do
    opt = [ip: {0,0,0,0}, active: false]
    {:ok, socket} = :gen_udp.open(port, opt)
    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    {:ok, packet} = :gen_udp.recv(socket, 4)
    Task.start_link(fn -> receive_message(packet) end)
    loop_acceptor(socket)
  end

  def receive_message(packet) do
    {_, _, message} = packet
    IO.puts message
  end

  def broadcaster(_port) do
    {:ok}
  end
end
