USER_POOL_ID=$1
if [ ! -e result ]; then
  mkdir result
fi

count=500
aws cognito-idp list-users --user-pool-id $USER_POOL_ID --max-items $count > result/0.log

for ((i=1; i<200; i++)); do
  sleep 2
  token=`cat result/$((i-1)).log | jq -r '.NextToken'`
  echo "$i $token"
  if [ "$token" = "null" ]; then
    break
  fi
  aws cognito-idp list-users --user-pool-id $USER_POOL_ID --max-items $count --starting-token $token > result/${i}.log
done

cat result/*.log | jq -r '.Users[] | [.UserStatus, .Username] | @csv' > user_list_all.csv