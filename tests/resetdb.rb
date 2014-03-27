client = MongoClient.new
client.db('farn_test.db').delete
puts  'farn_test_db deleted'
