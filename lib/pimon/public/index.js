$(function () {
  var i = 0,
      titleStats,
      rotateFaviconInterval,
      ws;
  
  function changeFavicon(chartStats) {
    titleStats = [];

    for (var probe in chartStats) {
      if (probe !== 'colors') {
        var pieChartOption = {
          'legend' : probe,
          'stat' : chartStats[probe].value,
          'color' : stats.colors[probe],
          'unit' : chartStats[probe].unit
        }
        titleStats.push(pieChartOption);
      }
    }

    i = 0;
    if (rotateFaviconInterval === undefined) {
      rotateFavicon(titleStats);
      rotateFaviconInterval = setInterval(function() { rotateFavicon(titleStats); }, 2000);
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

  function updateSingleStats(singleStats) {
    for (var probe in singleStats) {
      var probeReading = stats.single[probe].value;

      if (stats.single[probe].unit !== undefined) {
        probeReading = probeReading + ' ' + stats.single[probe].unit;
      }

      $('#' + probe + ' .stat').text(probeReading);
    }
  }

  function updateCharts(chartStats) {
    for (var probe in chartStats) {
      if (chartTimeSeries[probe] === undefined) {
        chartTimeSeries[probe] = new TimeSeries();
      }
      if (charts[probe] === undefined) {
        chartOptions = {
          millisPerPixel: 100,
          maxValue: 100,
          minValue: 0,
          grid:{ millisPerLine: 10000 },
          timestampFormatter:SmoothieChart.timeFormatter
        }
        
        charts[probe] = new SmoothieChart(chartOptions);

        charts[probe].addTimeSeries(chartTimeSeries[probe], { strokeStyle: stats.colors[probe], fillStyle: 'rgba(0, 255, 0, 0.2)', lineWidth: 2 });
        charts[probe].streamTo(document.getElementById(probe + '_chart'), 10000);
      }
      chartTimeSeries[probe].append(Date.parse(chartStats[probe].date), chartStats[probe].value);
    }
  }

  var chartTimeSeries = [],
      charts = [],
      ws = new WebSocket('ws://' + window.location.host + '/stats'),
      stats;

  ws.onclose = function()  { alert('Connection to Pimon server lost...'); };

  ws.onmessage = function(message) {
    stats = $.parseJSON(message.data);

    updateSingleStats(stats.single);
    updateCharts(stats.charts);
    changeFavicon(stats.charts);
  };
});
