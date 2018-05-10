//
//  BarChartViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/10.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import Charts
class BarChartViewController: UIViewController, ChartViewDelegate {
    @IBAction func zoomback(_ sender: Any) {
        self.barChartView.zoomToCenter(scaleX: 0, scaleY: 0)
    }
    
    var passedValue: [String]?
 let dangerous = ["毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    let countM = ["10701", "10702", "10703"]
    var months = ["毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    var colors = [UIColor.yellow, UIColor.red, UIColor.orange]
//    var numbers = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    let unitsSold1 = [15.0, 15.0, 15.0, 15.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    @IBOutlet var barChartView: BarChartView!

    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 50.0, 25.0, 57.0, 60.0, 28.0, 17.0, 47.0]
    let unitsBought = [10.0, 14.0, 60.0, 13.0, 2.0, 10.0, 15.0, 18.0, 25.0, 05.0, 10.0, 19.0]
    let xaxisValue: [String] = ["毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(passedValue!)
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - ChartView Delegate -
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        //        print("\(entry.value) in \(xaxisValue[entry.x])")
    }

    // MARK: - General Methods -
    func setupView() {

        //legend
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.yOffset = 10.0
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        legend.textColor = UIColor.black

        // Y - Axis Setup
        let yaxis = barChartView.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        yaxis.labelTextColor = UIColor.black
        yaxis.axisLineColor = UIColor.black

        barChartView.rightAxis.enabled = false

        // X - Axis Setup
        let xaxis = barChartView.xAxis
        let formatter = CustomLabelsXAxisValueFormatter()//custom value formatter
        formatter.labels = self.xaxisValue
        xaxis.valueFormatter = formatter

        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .bottom
        xaxis.labelTextColor = UIColor.black
        xaxis.centerAxisLabelsEnabled = true
        xaxis.axisLineColor = UIColor.black
        xaxis.granularityEnabled = true
        xaxis.enabled = true

        barChartView.delegate = self
        barChartView.noDataText = "沒有危險呢！"
        barChartView.noDataTextColor = UIColor.black
        barChartView.chartDescription?.textColor = UIColor.clear

        setChart()
    }

    func setChart() {
        guard let passedValue = passedValue, passedValue.count > 0 else {
            return
        }
        var data = [BarChartDataSet]()
        for jtem in 0..<countM.count {
            var numbers = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

            var dataEntries: [BarChartDataEntry] = []
            for crime in 0..<dangerous.count{
                
                for value in passedValue {
                    if (value.range(of: dangerous[crime])) != nil && (value.range(of: countM[jtem]) != nil) {
                        numbers[crime] += 1
                    }
                }
            }

            for item in 0..<numbers.count {
                let dataEntry = BarChartDataEntry(x: Double(item), y: (numbers[item]))
                dataEntries.append(dataEntry)

            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: countM[jtem])
            chartDataSet.colors = [colors[jtem]]
//            chartDataSet.drawValuesEnabled = false
            data.append(chartDataSet)

        }
        let dataSets: [BarChartDataSet] = data
        let chartData = BarChartData(dataSets: dataSets)

        let groupSpace = 0.4
        let barSpace = 0.03
        let barWidth = 0.2

        chartData.barWidth = barWidth

        barChartView.xAxis.axisMinimum = 0.0
        barChartView.xAxis.axisMaximum = 0.0 + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(self.xaxisValue.count)

        chartData.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace)

        barChartView.xAxis.granularity = barChartView.xAxis.axisMaximum / Double(self.xaxisValue.count)

        barChartView.data = chartData

        barChartView.notifyDataSetChanged()
        barChartView.setVisibleXRangeMaximum(4)
//        barChartView.animate(yAxisDuration: 1.0, easingOption: .linear)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        chartData.setValueTextColor(UIColor.black)
    }

}

class CustomLabelsXAxisValueFormatter: NSObject, IAxisValueFormatter {

    var labels: [String] = []

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let count = self.labels.count

        guard let axis = axis, count > 0 else {

            return ""
        }

        let factor = axis.axisMaximum / Double(count)

        let index = Int((value / factor).rounded())

        if index >= 0 && index < count {

            return self.labels[index]
        }

        return ""
    }
}


