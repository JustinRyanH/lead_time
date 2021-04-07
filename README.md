# lead_time
Use New Relic and GitHub? Use this to gather the raw data to calculate lead time and deploy frequency for your Accelerate Devops Metrics!


## How to Use

Create a `keys.rb` file in root of directory and replace the set values for variables with your credentials 

keys.rb

```ruby
NEW_RELIC_API_KEY="<NEW_RELIC_API_KEY>"
GITHUB_TOKEN="<GITHUB_TOKEN_KEY>"
APP_ID="NEW_RELICAPP_ID"
```

From ROOT directory Run

```bash
ruby ./lib/run.rb
```

Application will create a `deployments.csv` in repository root directory

Use CSV as needed
