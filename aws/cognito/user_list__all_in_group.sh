
USER_POOL_ID=$1
group=＄2
if [ ! -e result_$group ]; then
  mkdir result_$group
fi

count=500
aws cognito-idp list-users-in-group --user-pool-id $USER_POOL_ID --group-name $group --max-items $count > result_$group/0.log

for ((i=1; i<200; i++)); do
  sleep 2
  token=`cat result_$group/$((i-1)).log | jq -r '.NextToken'`
  echo "$i $token" 
  if [ "$token" = "null" ]; then
    break
  fi 
  aws cognito-idp list-users-in-group --user-pool-id $USER_POOL_ID --group-name $group --max-items $count --starting-token $token > result_$group/${i}.log
done

cat result_$group/*.log | jq -r '.Users[] | [.UserStatus, .Username] | @csv' > user_list_all_in_group_${group}.csv 

