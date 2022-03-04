class Chart
  attr_accessor :column,:data,:options,:name

  def self.to_js_date(d)
    a = Date.parse(d)
    "#{a.year},#{a.mon - 1},#{a.mday}"
  end

  def initialize(column,data,options,name)
    @column = column
    @data = data
    @options = options
    @name = name
    @chart_type = 'ColumnChart'
  end

  # body部分に表示するスクリプト
  def body_script
    erb = ERB.new(<<-EOS,nil,'-')
<div id="<%=@name%>"></div>
EOS
    erb.result(binding)
  end

  def header_script
    erb = ERB.new(<<-EOS,nil,'-')
<script type="text/javascript">
google.load('visualization', '1.0', {'packages':['corechart']});
google.setOnLoadCallback(drawChart);

function drawChart() {
  var data = new google.visualization.DataTable();
  <%- @column.each do |c| -%>
  data.addColumn('<%=c.keys[0]%>','<%=c.values[0]%>');
  <%- end -%>
  ]);

  var options ={
    width: 4800,
    height: 600
  };

  var chart = new google.visualization.<%=@chart_type%>(document.getElementById('<%=@name%>'));
  chart.draw(data, options);
}
</script>
EOS
    erb.result(binding)
  end

  def data_format(d)
    d.inspect
  end

end

# BarChart
class BarChart < Chart
  def initialize(column,data,options,name)
    super
    @chart_type = 'ColumnChart'
  end

  def data_format(d)
    "'#{d.keys[0]}',#{d.values[0]}"
  end
end
