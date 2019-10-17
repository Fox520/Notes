const graphql = require("graphql");
const _ = require("lodash");

const {
    GraphQLObjectType,
    GraphQLString,
    GraphQLSchema,
    GraphQLInt,
    GraphQLList,
    GraphQLNonNull} = graphql;

// dummy data
var notices = [ 
    {topic: 'the first topic', description: 'the first description', id: '1', day: 10,  weekNumber: 4, month: 8},
    {topic: 'the second topic', description: 'the second description', id: '2', day: 4, weekNumber: 8, month: 10},
    {topic: 'the third topic', description: 'the third description', id: '3', day:5, weekNumber: 15, month: 9}
];

const instance_port_pool = [9091, 9092, 9093, 9094];

const NoticeType = new GraphQLObjectType({
    name: 'Notice',
    fields: () => ({
        id: {type: GraphQLInt},
        topic: {type: GraphQLString},
        description: {type: GraphQLString},
        day: {type: GraphQLInt},
        weekNumber: {type: GraphQLInt},
        month: {type: GraphQLInt}
    })
});

const RootQuery = new GraphQLObjectType({
    // entry to graph
    name: 'RootQueryType',
    fields: {
        notice: {
            type: NoticeType,
            args: {id: {type:GraphQLInt}},
            description: 'Return notice of specified id',
            resolve(parent, args){
                // code to get data from source
                return _.find(notices, {id: args.id});
            }
        },
        notices: {
            type: new GraphQLList(NoticeType),
            description: 'Returns all notices',
            resolve(parent, args){
                // code to get data from source
                return notices;
            }
        },
        // heck, doing this to keep it simple and easier
        dayNotices: {
            type: new GraphQLList(NoticeType),
            args: {day: {type: GraphQLInt}},
            description: 'Return notices of specific day',
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {day: args.day});
            }
        },
        weekNotices: {
            type: new GraphQLList(NoticeType),
            args: {weekNumber: {type:GraphQLInt}},
            description: 'Return notices of specific week',
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {weekNumber: args.weekNumber});
            }
        },
        monthNotices: {
            type: new GraphQLList(NoticeType),
            args: {month: {type:GraphQLInt}},
            description: 'Return notices of specific month',
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {month: args.month});
            }
        }    
    }
})

const Mutation = new GraphQLObjectType({
    name: 'Mutation',
    fields: {
        addNotice: {
            type: NoticeType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLInt)},
                topic: {type: new GraphQLNonNull(GraphQLString)},
                description: {type: GraphQLString},
                day: {type: new GraphQLNonNull(GraphQLInt)},
                weekNumber: {type: new GraphQLNonNull(GraphQLInt)},
                month: {type: new GraphQLNonNull(GraphQLInt)}
            },
            resolve(parent, args){
                // code to send data to random server instance
                // ...
                return args
            }
        },
        updateNotice: {
            type: NoticeType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLInt)},
                topic: {type: GraphQLString},
                description: {type: GraphQLString},
                day: {type: GraphQLInt},
                weekNumber: {type: GraphQLInt},
                month: {type: GraphQLInt}
            },
            resolve(parent, args){
                // code to send data to random server instance
                // ...
                return args
            }
        },
        removeNotice: {
            type: NoticeType,
            args: {
                id: {type: new GraphQLNonNull(GraphQLInt)}
            },
            resolve(parent, args){
                // code to send data to random server instance
                // ...
                return args
            }
        }
    }
});

module.exports = new GraphQLSchema({
    query: RootQuery,
    mutation: Mutation
});