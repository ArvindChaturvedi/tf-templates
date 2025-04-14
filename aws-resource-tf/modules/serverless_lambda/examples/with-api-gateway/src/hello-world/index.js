exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const name = event.queryStringParameters?.name || 'World';
  
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type'
    },
    body: JSON.stringify({
      message: `Hello, ${name}!`,
      timestamp: new Date().toISOString()
    })
  };
  
  return response;
}; 