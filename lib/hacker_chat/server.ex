defmodule HackerChat.Server do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    opt = [ip: {0,0,0,0}, active: false]
    {:ok, socket} = :gen_udp.open(4040, opt)

    children = [
      supervisor(Task.Supervisor, [[name: HackerChat.TaskSupervisor]]),
      worker(Task, [HackerChat.Server, :accept, [socket]], id: HackerChat.Receiver),
      #worker(Task, [HackerChat.Server, :broadcast, [socket]], id: HackerChat.Broadcaster)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    broadcast(socket)
  end

  def accept(socket) do
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

  def broadcast(socket) do
    :inet.setopts(socket,[broadcast: true])
    loop_broadcaster(socket)
  end

  def loop_broadcaster(socket) do
    IO.puts "start broadcast loop"
    message = IO.read(:line)
    :gen_udp.send(socket, {255,255,255,255}, 4040, message)
    loop_broadcaster(socket)
  end
end
