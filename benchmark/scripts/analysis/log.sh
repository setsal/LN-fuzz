#!/bin/sh

rm -f log.md

touch log.md

echo "## $1 Log" >> log.md

printf "\n\n## AFLDEV\n\n" >> log.md

echo "### cov_over_time" >> log.md
printf "+ start: %s\n" $(head -n 2 out-$1-afldev-1/cov_over_time.csv | tail -n 1) >> log.md
printf "+ end: %s\n" $(tail -n 1 out-$1-afldev-1/cov_over_time.csv) >> log.md
printf "+ line: %s\n\n" $(wc -l out-$1-afldev-1/cov_over_time.csv | cut -d ' ' -f 1) >> log.md


printf "### fuzzer stat\n" >> log.md
printf "\`\`\`\n" >> log.md
cat out-$1-afldev-1/fuzzer_stats >> log.md
printf "\`\`\`" >> log.md

### AFLNET

printf "\n\n## AFLNET\n\n" >> log.md

echo "### cov_over_time" >> log.md

printf "+ start: %s\n" $(head -n 2 out-$1-aflnet-1/cov_over_time.csv | tail -n 1) >> log.md
printf "+ end: %s\n" $(tail -n 1 out-$1-aflnet-1/cov_over_time.csv) >> log.md
printf "+ line: %s\n\n" $(wc -l out-$1-aflnet-1/cov_over_time.csv | cut -d ' ' -f 1) >> log.md


printf "### fuzzer stat\n" >> log.md
printf "\`\`\`\n" >> log.md
cat out-$1-aflnet-1/fuzzer_stats >> log.md
printf "\`\`\`" >> log.md