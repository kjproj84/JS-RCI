function abcde()
{  var sql = `
    SELECT
      h_bond_acceptor_count,
      COUNT(*) AS total
    FROM drugs WHERE h_bond_acceptor_count IS NOT NULL
    GROUP BY h_bond_acceptor_count
    ORDER BY h_bond_acceptor_count
  `;
   var tmpv10 = sql;
   var data = alasql(tmpv10);
   var tmpv13 = data;
   var output = tmpv13;
return output;
}//15

function abcde2()
{
  var sql = `
   WITH intervals AS (
      SELECT CAST(molecular_weight AS INT) / 10.0* 10 AS weight_interval
      FROM drugs WHERE molecular_weight IS NOT NULL AND CAST(molecular_weight AS INT)< 1000
      )
       SELECT
         weight_interval,
         count(*) AS total
       FROM intervals
       GROUP BY weight_interval
       ORDER BY weight_interval;
         `
   var tmpv10 = sql;
   var data = alasql(tmpv10);
   var tmpv13 = data;
   var output = tmpv13;
return output;
} //20

const IS_SYNC = false;
if (IS_SYNC) {
  var data= abcde();
  const labels = data.map(obj => obj.h_bond_acceptor_count)
  const values = data.map(obj => obj.total)
  plot('#ct-chart-h-bond', labels, values, 'Number of H-bond Acceptors');
}//default: non-blocking async using Promise
else {
    new Promise((resolve, reject) => {
        var out_abcDe = abcde();
        resolve(out_abcDe);
    }).then(
        res => {
            var data = res;
            const labels = data.map(obj => obj.h_bond_acceptor_count)
            const values = data.map(obj => obj.total)
            plot('#ct-chart-h-bond', labels, values, 'Number of H-bond Acceptors');
        });
}

const IS_SYNC = false;
if (IS_SYNC) {
  var data= abcde2();
  const labels = data.map(obj => obj.h_bond_acceptor_count)
  const values = data.map(obj => obj.total)
  plot('#ct-chart-h-bond', labels, values, 'Number of H-bond Acceptors');
}//default: non-blocking async using Promise
else {
    new Promise((resolve, reject) => {
        var out_abcDe = abcde2();
        resolve(out_abcDe);
    }).then(
        res => {
            var data = res;
            const labels = data.map(obj => obj.weight_interval)
            const values = data.map(obj => obj.total)
            plot('#ct-chart-molecular-weights', labels, values, 'Molecular Weight (Daltons)')
        });
}

function plot(cssSelector, labels, values, xAxisTitle) {
  const max = Math.max.apply(null, values)
  const axisX = { showLabel: true }
  // show fewer labels if there are a ton of them
  if (labels.length > 60) {
    axisX.labelInterpolationFnc = (value, index) => {
      return index % 5  === 0 ? value : null;
    }
  }
  var chart = new Chartist.Bar(cssSelector, {
    labels,
    series: [ values ]
  }, {
    axisX,
    axisY: {
      onlyInteger: true
    },
    plugins: [
      Chartist.plugins.ctAxisTitle({
        axisX: {
          axisTitle: xAxisTitle,
          axisClass: 'ct-axis-title',
          offset: { x: 0, y: 30 },
          textAnchor: 'middle'
        },
        axisY: {
          axisTitle: 'Number of Compounds',
          axisClass: 'ct-axis-title',
          offset: { x: 0, y: 0 },
          textAnchor: 'middle',
          flipTitle: false
        }
      })
    ]
  })

  // on each draw event, overwrite the default bar color with something scaled to the maximum value
  chart.on('draw', function(context) {
    if(context.type === 'bar') {
      context.element.attr({
        style: 'stroke: hsl(' + Math.floor(Chartist.getMultiValue(context.value) / max * 100) + ', 50%, 50%);'
      });
    }
  });
}
