function get_shortcut_ws(url, on_notify, on_protocol, on_open, on_close) {
    var shortcut_ws = new WebSocket(url);

    shortcut_ws.on_notify = on_notify;
    shortcut_ws.on_protocol = on_protocol;
    if (on_open) shortcut_ws.onopen = on_open;
    if (on_close) shortcut_ws.onclose = on_close;

    shortcut_ws.onmessage = function(e) {
        if (e.data == "ACK") {
            $("#auth_panel").remove();
        } else if (e.data == "NAK") {
            alert("Invalid Auth Code");
        }
        console.debug("onmessage", e.data);
        var msg = $.evalJSON(e.data);
        op = msg["op"];
        channel = msg["channel"];
        data = msg["data"];
        if (op == "notify") {
            this.on_notify(channel, data);
        } else if (op == "protocol") {
            this.on_protocol(channel, data);
        }
    }

    shortcut_ws.send_message = function(op, channel, data) {
    	var msg = {op: op, channel: channel};
	    if (data) msg['data'] = data;
        console.debug("send_message", op, channel, msg);
    	return this.send($.toJSON(msg));
    }

    shortcut_ws.authenticate = function(auth_code) {
        console.debug("authenticate", auth_code);
    	return this.send(auth_code);
    }

    shortcut_ws.listen_channel = function(channel, data) {
        this.send_message("listen", channel, data);
    }

    shortcut_ws.control_channel = function(channel, data) {
        this.send_message("control", channel, data);
    }

    return shortcut_ws;
}

channel_protocols = {};

on_notify = function (channel, data) {
    console.info("on_notify", channel, data);
    var type = data["type"];
    if (type == "listening") {
        $('<option value="' + channel + '">' + channel + '</option>').appendTo("#channels");
        if ($("#channels").children().length == 1) {
            $("#channels").trigger("change");
        }
    }else if (type == "closed") {
        $('#channels option[value="' + channel + '"]').remove();
    }else{
        var notify_display = prettyPrint({
            channel: channel,
            data: data
        },{
            maxDepth: 6
        });
        $("#display").prepend(notify_display);
    }
}

on_protocol = function (channel, data) {
    console.info("on_protocol", channel, data);
    channel_protocols[channel] = data;
    ws.listen_channel(channel);
}

on_open = function() {
    console.info('WebSocket opened');
}

on_close = function() {
    console.info('WebSocket closed');
}

$(document).ready(function() {
    $("#channels").change(function() {
        var channel = ($(this).val());
        var protocol = channel_protocols[channel];
        $("#cmds").empty();
        var cmds = protocol["cmds"];
        for (var cmd in cmds) {
            if (cmds.hasOwnProperty(cmd)) {
                $('<option value="' + cmd + '">' + cmd + '</option>').appendTo("#cmds");    
            }
        }
    });
    $("#control").click(function() {
        var control_data = $.evalJSON("{" + $("#parameters").val() + "}");
        control_data["cmd"] = $("#cmds").val(); 
        ws.control_channel($("#channels").val(), control_data);
    });
    $("#clear").click(function() {
        $("#display").empty();
    });
    $("#auth").click(function() {
        ws.authenticate($("#auth_code").val());
    });
});


