# client.rb
require 'drb/drb'
require 'socket'

def local_ip
  addr = Socket.ip_address_list.find { |a| a.ipv4? && !a.ipv4_loopback? && !a.ipv4_multicast? }
  addr ? addr.ip_address : '127.0.0.1'
end

SERVER_HOST = '127.0.0.1'
URI = "druby://#{SERVER_HOST}:8787"

proxy = DRbObject.new_with_uri(URI)

print 'Valor do investimento inicial: '
invest = Float(STDIN.gets)

print 'Taxa de juros mensal (%): '
taxa = Float(STDIN.gets)

print 'Número de meses: '
meses = Integer(STDIN.gets)

resultado = proxy.calcular_juros(invest, taxa, meses, local_ip)

puts "\n--- Resultado ---"
puts "Total ao final:     R$ #{'%.2f' % resultado['total']}"
puts "Total de juros:     R$ #{'%.2f' % resultado['total_juros']}"
puts "Juros por mês e saldo acumulado:"
resultado['juros_mensais'].each_with_index do |j, i|
  saldo = resultado['saldos'][i]
  puts "  M#{i+1}: juros = R$ #{'%.2f' % j} | saldo = R$ #{'%.2f' % saldo}"
end
