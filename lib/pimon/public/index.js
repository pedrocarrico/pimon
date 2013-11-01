$(function () {
  var i = 0,
      titleStats,
      rotateFaviconInterval,
      ws;
  
  function changeFavicon(o) {
    titleStats = [
      { 'legend' : 'CPU', 'stat' : o.cpu.stats[o.cpu.stats.length - 1], 'color' : o.cpu.color, 'unit' : o.cpu.unit } ,
      { 'legend' : 'MEM', 'stat' : o.mem.stats[o.mem.stats.length - 1], 'color' : o.mem.color, 'unit' : o.mem.unit } ,
      { 'legend' : 'SWAP', 'stat' : o.swap.stats[o.swap.stats.length - 1], 'color' : o.swap.color, 'unit' : o.swap.unit},
      { 'legend' : 'DISK', 'stat' : o.disk.stats[o.disk.stats.length - 1], 'color' : o.disk.color, 'unit' : o.disk.unit},
      { 'legend' : 'TEMP', 'stat' : o.temp.stats[o.temp.stats.length - 1], 'color' : o.temp.color, 'unit' : o.temp.unit} ];
    i = 0;
    if (rotateFaviconInterval === undefined) {
      rotateFavicon(titleStats);
      rotateFaviconInterval = setInterval(function() { rotateFavicon(titleStats); }, 3000);
    }
  }
  
  function rotateFavicon(titleStats) {
    Piecon.setOptions({
      color: titleStats[i].color, // Pie chart color
      background: '#bbb', // Empty pie chart color
      shadow: '#fff', // Outer ring color
      fallback: 'force' // Toggles displaying percentage in the title bar (possible values - true, false, 'force')
    });
    Piecon.setProgress(titleStats[i].stat);
    
    $('title').text(titleStats[i].stat + titleStats[i].unit + ' ' + titleStats[i].legend);
    i++;
    if (i >= titleStats.length) {
      i = 0;
    }
  }
  
  function drawChart(o) {
    new Highcharts.Chart({
      chart: {
        renderTo: 'chart',
        type: 'line',
        marginRight: 130,
        marginBottom: 25
      },
      title: {
        text: 'Pimon',
        x: -20
      },
      subtitle: {
        text: o.hostname,
        x: -20
      },
      xAxis: {
        categories: o.time.stats
      },
      yAxis: {
        title: {
            text: 'Usage'
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }],
        max: 100,
        min: 0
      },
      tooltip: {
        formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          this.x +': '+ this.y + (this.series.name === 'temp' ? o.temp.unit : '%');
        }
      },
      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'top',
        x: -10,
        y: 100,
        borderWidth: 0
      },
      series: [{
        name: 'cpu',
        color: o.cpu.color,
        data: o.cpu.stats
      },
      {
        name: 'mem',
        color: o.mem.color,
        data: o.mem.stats
      },
      {
        name: 'swap',
        color: o.swap.color,
        data: o.swap.stats
      },
      {
        name: 'disk',
        color: o.disk.color,
        data: o.disk.stats
      },
      {
        name: 'temp',
        color: o.temp.color,
        data: o.temp.stats
      }],
      credits: {
        enabled: false
      }
    });
  }
  
  function maybeInsertWordConnector(text, connector) {
    return text !== '' ? text + connector : text;
  }
  
  function pluralize(count, word) {
    return ((count === '1') ? ' ' + word : ' ' + word + 's');
  }
  
  function formatUptime(uptimeArray) {
    var uptime = '',
        days =    uptimeArray[0],
        hours =   uptimeArray[1],
        minutes = uptimeArray[2],
        seconds = uptimeArray[3];
    
    if (days !== '0') {
      uptime = days + ' ' + pluralize(days, 'day');
    }
    
    if (hours !== '0') {
      uptime = maybeInsertWordConnector(uptime, ', ') + hours + ' ' + pluralize(hours, 'hour');
    }
    
    if (minutes !== '0') {
      uptime = maybeInsertWordConnector(uptime, ', ') + minutes + ' ' + pluralize(minutes, 'minute');
    }
    
    if (seconds !== '0') {
      uptime = maybeInsertWordConnector(uptime, ' and ') + seconds + ' ' + pluralize(seconds, 'second');
    }
    return uptime;
  }
  
  ws = new WebSocket('ws://' + window.location.host + window.location.pathname);
  ws.onclose = function()  { alert('Connection to Pimon server lost...'); };
  ws.onmessage = function(m) {
    var o = $.parseJSON(m.data);
    drawChart(o);
    changeFavicon(o);
    $('#uptime .up').text(formatUptime(o.uptime.slice(-1)[0]));
  };
});
