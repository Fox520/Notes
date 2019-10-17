const graphql = require("graphql");

const {GraphQLObjectType, GraphQLString} = graphql;

const NoticeType = new GraphQLObjectType({
    name: 'Notice',
    fields: () => ({
        id: {type: GraphQLString},
        topic: {type: GraphQLString},
        description: {type: GraphQLString}

    })
});