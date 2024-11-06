# PaddleScore APP 前端开发进度
## 项目框架
### 首界面
- [x] 导航栏切换页面
- [x] 导航栏收起与展开
- [x] 弹出框创建比赛页面
- [x] 弹出框导入Excel
- [x] 创建比赛显示导航栏
- [x]  处理Excel逻辑
- [x]  点击确认后显示确认信息页面
### 管理赛事页面
- [] 赛事列表显示
- [] 批量操作
- [] 右键删除功能
- [] 找回记录
### 比赛流程页面  
- [] 比赛流程列表
- [] 短距离比赛表单显示分组
### 分组显示页面

### 组别分组页面
### 男女分组页面
## 项目细化
### 首页
- [x] 导航栏创建比赛
- [] 根据数据库创建导航栏
- [] 当设备宽度不足时，导航条显示明确比赛名称
- [] 根据数据库显示比赛数量
### 创建比赛页面
- [] 弹框位于右方页面中心
- [] 创建比赛页面的表单验证，比赛名称不能重复
- [] 上传名单后按钮变成修改名单
### 管理赛事页面
- [] 赛事列表显示
- [] 批量操作
### RacePage
- [] ListView优化页面
### LongDistancePage
- [] 提高读取速度OR完善加载动画
- [] 固定表头
````
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// ...

// 创建数据源类
class _MyDataSource extends DataGridSource {
  _MyDataSource({required List<Map<String, dynamic>> tableData}) {
    _tableData = tableData
        .map<DataGridRow>((dataRow) => DataGridRow(cells: [
              DataGridCell<String>(columnName: '编号', value: dataRow['id'].toString()),
              DataGridCell<String>(columnName: '姓名', value: dataRow['name'].toString()),
              DataGridCell<String>(columnName: '单位', value: dataRow['team'].toString()),
              DataGridCell<String>(columnName: '组别', value: dataRow['division'].toString()),
            ]))
        .toList();
  }

  List<DataGridRow> _tableData = [];

  @override
  List<DataGridRow> get rows => _tableData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}

// ...

return SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SizedBox(
      height: 300, // 设置表格高度
      width: 500, // 设置表格宽度
      child: SfDataGrid( // 使用 SfDataGrid
        source: _MyDataSource(tableData: _tableData), // 设置数据源
        columns: const [
          GridColumn(columnName: '编号', label: Text('编号')),
          GridColumn(columnName: '姓名', label: Text('姓名')),
          GridColumn(columnName: '单位', label: Text('单位')),
          GridColumn(columnName: '组别', label: Text('组别')),
        ],
        frozenRowsCount: 1, // 固定首行标题
      ),
    ),
  ),
);
````
