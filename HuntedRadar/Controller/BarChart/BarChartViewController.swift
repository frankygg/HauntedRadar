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
    func didChangeBarChartView() {
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

    }
    

    //IBOutlet var
    @IBOutlet var barChartView: BarChartView!

    //local var
    var passedValue: [String]?
    var colors = [UIColor.yellow, UIColor.red, UIColor.orange]
    var xaxisValue: [String] = [String]()
    
    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.delegate = self
        setupView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "full_screen_exit"), style: .done, target: self, action: #selector(zoomback))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
        


    }
    

    @objc func zoomback(_ sender: UIBarButtonItem) {
            sender.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
            self.barChartView.zoomToCenter(scaleX: 0, scaleY: 0)
            print("zooommmmmmmmmmm in")
            }
    
    @objc func handleTap() {
                navigationItem.rightBarButtonItem?.tintColor = UIColor.white

    }

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
            print("scaled")

    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
            print("translated")
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("print the oooooooooooo")
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("print nothing selected")

    }
    func chartViewChanged(_ chartView: ChartViewBase) {
                navigationItem.rightBarButtonItem?.tintColor = UIColor.white

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - General Methods -
    func setupView() {
        setChart()

        //legend
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
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
        yaxis.labelTextColor = UIColor.gray
        yaxis.axisLineColor = UIColor.black
        yaxis.axisLineWidth = 1.5

        barChartView.rightAxis.enabled = false

        // X - Axis Setup
        let xaxis = barChartView.xAxis
        let formatter = CustomLabelsXAxisValueFormatter()//custom value formatter
        formatter.labels = self.xaxisValue
        xaxis.valueFormatter = formatter

        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .bottom
        xaxis.labelTextColor = UIColor.gray
        xaxis.centerAxisLabelsEnabled = true
        xaxis.axisLineColor = UIColor.black
        xaxis.axisLineWidth = 1.5
        xaxis.granularityEnabled = true
        xaxis.labelFont = UIFont(name: "PingFangTC-Regular", size: 10.0)!
        xaxis.enabled = true

        barChartView.noDataText = "沒有犯罪危險呢！"
        barChartView.noDataFont = UIFont(name: "PingFangTC-Regular", size: 20.0)!
        barChartView.noDataTextColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
        barChartView.chartDescription?.textColor = UIColor.clear

    }

    func setChart() {
        guard let passedValue = passedValue, passedValue.count > 0 else {
            return
        }
        var numberOfCrimeArray = [Double]()
        for item in MapViewConstants.dangerousWithUnluckyHouse {
        for value in passedValue {
            if value.range(of: item) != nil {
                xaxisValue.append(item)
                numberOfCrimeArray.append(0.0)
                break
            }
        }
        }
        var data = [BarChartDataSet]()
        for jtem in 0..<MapViewConstants.countMonth.count {
            var numbers = numberOfCrimeArray

            var dataEntries: [BarChartDataEntry] = []
            for crime in 0..<xaxisValue.count {

                for value in passedValue {
                    if (value.range(of: xaxisValue[crime])) != nil && (value.range(of: MapViewConstants.countMonth[jtem]) != nil) {
                        numbers[crime] += 1
                    }
                }
            }

            for item in 0..<numbers.count {
                let dataEntry = BarChartDataEntry(x: Double(item), y: (numbers[item]))
                dataEntries.append(dataEntry)

            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: MapViewConstants.countMonth[jtem])
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

