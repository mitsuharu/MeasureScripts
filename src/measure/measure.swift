import Foundation

/*
./dist/measure -e /bin/ls

*/

// MARK: - 引数のパース

// デフォルト値
var executablePath: String? = nil
var trialCount: Int = 1
var csvFileName: String = "result.csv"

// コマンドライン引数を手動でパース
// 例: measure -e /path/to/executable -c 5 -o output.csv
var args = CommandLine.arguments.dropFirst()  // 実行ファイル名は除外

while let arg = args.first {
    switch arg {
    case "-e":
        args = args.dropFirst()
        if let value = args.first {
            executablePath = value
            args = args.dropFirst()
        } else {
            print("Error: -e オプションには実行ファイルのパスを指定してください。")
            exit(1)
        }
    case "-c":
        args = args.dropFirst()
        if let value = args.first, let count = Int(value) {
            trialCount = count
            args = args.dropFirst()
        } else {
            print("Error: -c オプションには整数の試行回数を指定してください。")
            exit(1)
        }
    case "-o":
        args = args.dropFirst()
        if let value = args.first {
            csvFileName = value
            args = args.dropFirst()
        } else {
            print("Error: -o オプションには出力CSVファイル名を指定してください。")
            exit(1)
        }
    default:
        print("不明な引数: \(arg)")
        args = args.dropFirst()
    }
}

guard let execPath = executablePath else {
    print("Usage: \(CommandLine.arguments[0]) -e {実行ファイル} -c {試行回数} -o {CSVファイル名}")
    exit(1)
}

// MARK: - ps コマンドのパスを決定
// macOS では /bin/ps、Linux では /usr/bin/ps など環境に合わせる
let psPath: String = {
    let fm = FileManager.default
    if fm.fileExists(atPath: "/bin/ps") {
        return "/bin/ps"
    } else if fm.fileExists(atPath: "/usr/bin/ps") {
        return "/usr/bin/ps"
    } else {
        print("Error: ps コマンドが見つかりません。")
        exit(1)
    }
}()

// MARK: - プロセスの状態を取得する関数
/// 指定した PID のプロセスについて、ps コマンドで %CPU と RSS を取得する。
/// - Parameter pid: 監視対象のプロセスID
/// - Returns: (cpu: CPU使用率[%], rss: Resident Set Size[KB]) のタプル。取得できなければ nil を返す。
func getProcessStats(pid: pid_t) -> (cpu: Double, rss: Double)? {
    let psProcess = Process()
    psProcess.executableURL = URL(fileURLWithPath: psPath)
    // ps コマンドで %CPU と RSS（常駐セットサイズ）を取得
    psProcess.arguments = ["-p", "\(pid)", "-o", "%cpu=,rss="]

    let pipe = Pipe()
    psProcess.standardOutput = pipe

    do {
        try psProcess.run()
        psProcess.waitUntilExit()
    } catch {
        return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else {
        return nil
    }
    // 出力例: " 0.0  1234"
    let components = output.trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: " ", omittingEmptySubsequences: true)
    if components.count >= 2,
        let cpu = Double(components[0]),
        let rss = Double(components[1])
    {
        return (cpu, rss)
    }
    return nil
}

// MARK: - 試行結果の構造体
struct TrialResult {
    let executionTime: Double  // 実行時間 (秒)
    let maxCpu: Double  // 試行中に測定した最大 CPU 使用率 (%)
    let maxMemory: Double  // 試行中に測定した最大メモリ使用量 (RSS, KB)
}

var results = [TrialResult]()

// MARK: - 各試行の実行
for trial in 1...trialCount {
    print("試行 \(trial) / \(trialCount) を実行中...")

    // 試行開始時刻
    let startTime = Date()

    // Process を生成して実行
    let process = Process()
    process.executableURL = URL(fileURLWithPath: execPath)
    // ※必要に応じて process.arguments に引数を設定してください。

    do {
        try process.run()
    } catch {
        print("プロセスの起動に失敗しました: \(error)")
        exit(1)
    }

    // プロセスIDを取得
    let pid = process.processIdentifier

    // 試行中の最大値を記録する変数
    var maxCpuObserved = 0.0
    var maxMemoryObserved = 0.0

    // プロセスが終了するまで、0.1秒間隔で ps コマンドにより CPU とメモリを監視
    while process.isRunning {
        if let stats = getProcessStats(pid: pid) {
            if stats.cpu > maxCpuObserved { maxCpuObserved = stats.cpu }
            if stats.rss > maxMemoryObserved { maxMemoryObserved = stats.rss }
        }
        usleep(100_000)  // 100ミリ秒待機
    }

    // プロセスの終了を待機（念のため）
    process.waitUntilExit()

    let execTime = Date().timeIntervalSince(startTime)

    // 試行結果を保存
    let trialResult = TrialResult(
        executionTime: execTime,
        maxCpu: maxCpuObserved,
        maxMemory: maxMemoryObserved)
    results.append(trialResult)

    print(
        "試行 \(trial) 完了: 実行時間 \(String(format: "%.3f", execTime)) 秒, 最大 CPU \(maxCpuObserved)% , 最大メモリ \(maxMemoryObserved / 1000.0) MB"
    )
}

// MARK: - 結果の集計と平均値の計算
let totalTrials = Double(results.count)
let avgTime = results.reduce(0.0) { $0 + $1.executionTime } / totalTrials
let avgCpu = results.reduce(0.0) { $0 + $1.maxCpu } / totalTrials
let avgMemory = results.reduce(0.0) { $0 + $1.maxMemory } / totalTrials

print("\n--- 平均結果 (\(results.count) 試行) ---")
print("平均実行時間: \(String(format: "%.3f", avgTime)) 秒")
print("平均最大 CPU 使用率: \(String(format: "%.2f", avgCpu))%")
print("平均最大メモリ使用量: \(String(format: "%.2f", avgMemory / 1_000.0)) MB")

// MARK: - CSV 形式でファイルに出力
var csvText = "Trial,ExecutionTime(sec),MaxCPU(%),MaxMemory(KB)\n"
for (index, result) in results.enumerated() {
    csvText += "\(index+1),\(result.executionTime),\(result.maxCpu),\(result.maxMemory)\n"
}
csvText += "Average,\(avgTime),\(avgCpu),\(avgMemory)\n"

do {
    try csvText.write(toFile: csvFileName, atomically: true, encoding: .utf8)
    print("\n結果を CSV ファイル \(csvFileName) に書き出しました。")
} catch {
    print("CSV ファイルの書き出しに失敗しました: \(error)")
}
