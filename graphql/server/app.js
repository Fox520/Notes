const express = require('express')
const graphqlHTTP = require('express-graphql')
const schema = require('./schema/schema')
const cors = require('cors')

const app = express();

// allow cross origin request
app.use(cors())

app.use("/graphql", graphqlHTTP({
    schema,
    graphiql: true
}));

app.listen(4000, () => {
    console.log("listening for requests on port 4000")
})