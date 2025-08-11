## Basic GET Requests

# Test wildthings endpoint
curl http://localhost:4000/wildthings

# Test bears listing
curl http://localhost:4000/bears

# Test specific bear
curl http://localhost:4000/bears/1

# Test about page
curl http://localhost:4000/about

# Test 404 error
curl http://localhost:4000/nonexistent

## POST Requests

# Create a new bear (form data)
curl -X POST http://localhost:4000/bears \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "name=Baloo&type=Brown"

# Create a bear (JSON)
curl -X POST http://localhost:4000/bears \
  -H "Content-Type: application/json" \
  -d '{"name":"Yogi","type":"Grizzly"}'

## API Endpoints

# API bears list
curl http://localhost:4000/api/bears

# API create bear
curl -X POST http://localhost:4000/api/bears \
  -H "Content-Type: application/json" \
  -d '{"name":"Paddington","type":"Brown"}'

## DELETE Request
# Try to delete a bear (should return 403)
curl -X DELETE http://localhost:4000/bears/1

## Verbose Output

# See full HTTP headers and response
curl -v http://localhost:4000/bears

# See only response headers
curl -I http://localhost:4000/bears
