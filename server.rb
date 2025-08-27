# server.rb
require 'drb/drb'
require 'socket'

class JurosService
  def calcular_juros(investimento, taxa_percent, meses, client_ip)
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    raise ArgumentError, 'meses deve ser >= 1' if meses.to_i < 1
    raise ArgumentError, 'investimento deve ser > 0' if investimento.to_f <= 0

    taxa  = taxa_percent.to_f / 100.0
    valor = investimento.to_f

    juros_mensais = []
    saldos        = []

    meses.to_i.times do
      juro  = valor * taxa
      valor += juro
      juros_mensais << juro.round(2)
      saldos        << valor.round(2)
    end

    total        = valor.round(2)
    total_juros  = (total - investimento.to_f).round(2)

    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "[SERVIDOR] Requisição de #{client_ip} | Tempo: #{(t1 - t0).round(6)} s"

    { 'total' => total, 'total_juros' => total_juros,
      'juros_mensais' => juros_mensais, 'saldos' => saldos }
  end
end

FRONT_OBJECT = JurosService.new
URI = 'druby://127.0.0.1:8787'

DRb.start_service(URI, FRONT_OBJECT)
puts "[SERVIDOR] dRuby ativo em #{URI}"
DRb.thread.join
