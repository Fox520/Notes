const graphql = require("graphql");
const _ = require("lodash");

const {GraphQLObjectType, GraphQLString, GraphQLSchema} = graphql;

// dummy data
var notices = [
    {topic: 'the first topic', description: 'the first description', id: '1'},
    {topic: 'the second topic', description: 'the second description', id: '2'},
    {topic: 'the third topic', description: 'the third description', id: '3'}
];

const NoticeType = new GraphQLObjectType({
    name: 'Notice',
    fields: () => ({
        id: {type: GraphQLString},
        topic: {type: GraphQLString},
        description: {type: GraphQLString}

    })
});

const RootQuery = new GraphQLObjectType({
    // entry to graph
    name: 'RootQueryType',
    fields: {
        notice: {
            type: NoticeType,
            args: {id: {type:GraphQLString}},
            resolve(parent, args){
                // code to get data from source
                return _.find(notices, {id: args.id});
            }
        }
    }
})

module.exports = new GraphQLSchema({
    query: RootQuery
})