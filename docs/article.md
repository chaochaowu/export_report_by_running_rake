# 寫隻 rake 讓你一行指令輕鬆跑報表

## 什麼是 Rake？
Rake 是 Ruby 版的 Make，你可以想像成是一種任務程式工具。Rake 是以 Ruby 語法來編寫 `Rakefile` 或 `.rake` 檔案來建立任務（task），並在 Terminal 用 `$ rake` 指令來執行建立好的任務。

---
## Rails 中的 rake 指令
在 Rails 專案中，我們可以在 Terminal 輸入 `$ rake -T` 來查看目前可以使用的 rake 指令，而井字號（`#`）後面的文字描述是 task 的說明。

```ruby
rake db:create       # Creates the database from DATABASE_URL or config/database.yml for the ...
rake db:drop         # Drops the database from DATABASE_URL or config/database.yml for the cu...
rake db:migrate      # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)

# ...

rake routes          # Print out all defined routes in match order, with names
```
##### *下 `$ rake -T` 後，可以看到許多我們平常在 Rails 專案使用的指令。*

而在 Rails 5.0 以後的版本，Rails 提供可以使用 `$ rails` 代替 `$ rake` 多數指令的操作，所以你也能使用 `$ rails db:migrate`、`$ rails routes` 來執行，會得到與 rake 相同的結果。

---
## 一起動手寫隻 rake
接下來會簡單操作如何透過 rake 指令輸入 CSV 檔，並藉由資料庫現有資料與簡單的判斷條件，將判斷結果輸出在 CSV 檔上，不用再人工一行一行慢慢對資料填結果！

### 情境與需求
> 活動部門寄來一份 CSV 檔，內含多筆使用者 Email 資訊，要判斷這些 Email 的註冊時間是否在 12 月聖誕節期間內（2019-12-24 ~ 2019-12-31），活動部門希望回傳的 CSV 檔案能包含簡單的結果：「此 Email 註冊於期間內」、「此 Email 非在期間內註冊」，以利活動部門能根據結果來進行抽籤贈獎的活動。

### 事前準備
- 建立一個新的 Rails 專案，並使用 gem [Devise](https://github.com/plataformatec/devise) 做一個簡單可註冊的會員功能。

  你也可以直接到 GitHub clone [示範專案 export_report_by_running_rake](https://github.com/chaochaowu/export_report_with_rake)，輕鬆跟我一起用 rake 一行指令輸出報表！

- 準備一份 CSV 檔，header 需包含 Email 及 Result 兩個欄位，而資料需有多筆 Email 資訊。

### 開始寫能滿足需求的任務

**Step 1. 新增 Rake 執行檔案**

在 Rails app 根目錄下的 `lib/tasks` 新增 rake 檔案 `inspect_registration_date.rake`。

**Step 2. 給任務（task）名字和簡單的說明**

一開始我們會給任務（task）一個執行名字和簡短的說明。

```ruby
# inspect_registration_date.rake
desc "Inspect user registration date and export CSV file with result"
task :inspect_registration_date do
  # do something magic here
end
```

- `desc` 實際上並不會執行任何動作，只有在輸入指令 `$ rake -T` 時，才會顯示這段描述在 `#` 後面。

- `task` 方法可以為任務命名，用在輸入 rake 指令指定要跑的任務，以本次示範為例則是在 Terminal 輸入 `$ rake inspect_registration_date`。

```ruby
# Terminal environment
$ rake -T
rake inspect_registration_date    # Inspect user registration date and export CSV file with result

# ...
```

**Step 3. 依需求給予參數**

根據前面提到的需求，我們現在要做的任務是對輸入的 CSV 檔案的資料做檢查，所以會期望在輸入 rake 指令時能夠給予參數，以本次示範來說，這個參數就是要輸入的 CSV 檔案的路徑。

```ruby
desc "Inspect user registration date and export CSV file with result"
task :inspect_registration_date, [:file] => :environment do |task, args|
  # You can use args from here
end
```

可以用 `$ rake -T` 查看指令的變化已為 `rake inspect_registration_date[file]`，後面多了 `[file]` 作為指令接收參數用。

**Step 4. 將任務需求寫在 block 裡**

依照前提的需求，我們可以知道在這個任務要做的事情如下：
- 輸入 CSV 檔案
- 檢查 CSV 資料並在 Result 欄位加入判斷結果
- 輸出帶有結果的 CSV 檔案

接下來我們要將這三項要做的事情轉成程式碼寫進 block 裡，當我們輸入 rake 指令，呼叫任務 `inspect_registration_date` 時，就會自動執行 block 裡的程式碼。

```ruby
desc "Inspect user registration date and export CSV file with result"
task :inspect_registration_date, [:file] => :environment do |task, args|
  # Step 1. read importing CSV data
  csv_contents = CSV.read(args[:file].pathmap, headers: true)

  # Step 2. inspect user registration date and fill in result column
  csv_contents.each do |row|
    email = row['Email']

    # activity period
    activity_start_date = DateTime.new(2019, 12, 24)
    activity_end_date = DateTime.new(2019, 12, 31, 23).end_of_hour

    user_registration_date = User.find_by(email: email).created_at
    next row['Result'] = "此 Email 非在期間內註冊" unless user_registration_date.between?(activity_start_date, activity_end_date)
    row['Result'] = "此 Email 註冊於期間內"
  end

  # Step.3 export CSV file with result
  file_name = File.basename(args[:file], '.csv')
  File.open("/tmp/#{file_name}_result.csv", 'w') do |file|
    file.write(csv_contents)
  end
end
```

- 在 rake 檔案中沒有 `return` 可以使用，但可以使用相同效果的 `next`。以示範為例，用 `next` 搭配判斷條件，若條件不符，則會直接在 result 欄位填入「此 Email 非在期間內註冊」，並且程式會跳出 Step 2 的 block 不再往下執行。

**Step 5. 準備輸入用的 CSV 檔案並執行 rake 任務**

完成 rake 檔案後，請將事前準備好的 CSV 檔案放在 `/tmp` 資料夾下，接著在 Terminal 輸入**一行指令** `rake inspect_registration_date['/tmp/sample.csv']`，當任務執行完畢後，開啟 `/tmp/sample_result.csv` 檔案，此檔案就包含活動部門期望的結果，趕緊把這份檔案寄給活動部門就可以囉！🎉

- 關於輸入 CSV 的檔案位置，你也可以放在任何你想放的位置，只要記得更改程式中輸出的路徑為你想找到含結果的檔案位置，因為範例中輸出檔案路徑是放在 `/tmp` 資料夾下。

- 若在執行 rake 時發生錯誤 `NameError: uninitialized constant CSV`，請先確認 `config/application.rb` 是否有 `require 'csv'` library 到專案中。

---
## 總結

坦若你想對 rake 檔案中的程式碼進行測試，可以將 `task` block 裡的程式碼改寫成一個 Service Object，之所以要用 Service Object 改寫的原因在於我們無法測試 rake 檔案中的程式碼，但若改寫成 Service Object 這樣的 PORO（Plain Old Ruby Object），就可以對這段程式碼編寫測試囉！（改寫 Service Object 範例可見 [示範專案 export_report_by_running_rake](https://github.com/chaochaowu/export_report_with_rake)）

當你完成本篇文章的範例後，是否也跟筆者一樣覺得 Rake 很方便，可以執行各式各樣的任務呢？若當情境變成要在不同時間點，使用相同條件來判斷需求是否符合時，那寫完一隻 rake 之後，每次都只需要用**一行指令**就可以完成任務囉！🎉

---
## 參考資料
- [Rake (software) From Wikipedia](https://en.wikipedia.org/wiki/Rake_%28software%29)
- [The Rails Command Line](https://guides.rubyonrails.org/v4.1/command_line.html#rake)