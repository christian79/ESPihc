wifi.setmode(wifi.STATION)
wifi.sta.config("ssid","pass")
print(wifi.sta.getip())
labON = 3
labOFF = 4
entreON = 5
entreOFF = 6
gpio.mode(labON, gpio.OUTPUT)
gpio.mode(labOFF, gpio.OUTPUT)
gpio.mode(entreON, gpio.OUTPUT)
gpio.mode(entreOFF, gpio.OUTPUT)
tmr.start(1)

tmr.alarm(1, 100, 1, function()
    gpio.write(labON, gpio.LOW)
    gpio.write(labOFF, gpio.LOW)
    gpio.write(entreON, gpio.LOW)
    gpio.write(entreOFF, gpio.LOW)
    tmr.stop(1)
end)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1>IHC WEB</h1>";
        buf = buf.."<p>LAB   <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>ENTRE <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(labON, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(labOFF, gpio.HIGH);
        elseif(_GET.pin == "ON2")then
              gpio.write(entreON, gpio.HIGH);
        elseif(_GET.pin == "OFF2")then
              gpio.write(entreOFF, gpio.HIGH);
        end
        tmr.start(1)
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
