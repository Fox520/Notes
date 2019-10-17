const graphql = require("graphql");
const _ = require("lodash");

const {
    GraphQLObjectType,
    GraphQLString,
    GraphQLSchema,
    GraphQLID,
    GraphQLInt,
    GraphQLList,
    GraphQLScalarType} = graphql;

// dummy data
var notices = [ //day - month - year <- this format is suitable for upcoming events
    {topic: 'the first topic', description: 'the first description', id: '1', submissionDate: new Date('10-08-2019'), weekNumber: 4, month: 8},
    {topic: 'the second topic', description: 'the second description', id: '2', submissionDate: new Date('4-10-2019'), weekNumber: 8, month: 10},
    {topic: 'the third topic', description: 'the third description', id: '3', submissionDate: new Date('5-09-2019'), weekNumber: 15, month: 9}
];

// define date scalar
const GQDate = new GraphQLScalarType({
    name: "GQDate",
    description: "Date Type",
    parseValue(value){
        return value;
    },
    serialize(value){
        return value;
    },
    parseLiteral(ast){
        return new DataCue(ast.value);
    }
});

const NoticeType = new GraphQLObjectType({
    name: 'Notice',
    fields: () => ({
        id: {type: GraphQLID},
        topic: {type: GraphQLString},
        description: {type: GraphQLString},
        weekNumber: {type: GraphQLInt},
        month: {type: GraphQLInt},
        submissionDate: GQDate
    })
});

const RootQuery = new GraphQLObjectType({
    // entry to graph
    name: 'RootQueryType',
    fields: {
        notice: {
            type: NoticeType,
            args: {id: {type:GraphQLID}},
            resolve(parent, args){
                // code to get data from source
                return _.find(notices, {id: args.id});
            }
        },
        notices: {
            type: new GraphQLList(NoticeType),
            resolve(parent, args){
                // code to get data from source
                return notices;
            }
        },
        // heck, doing this to keep it simple and easier
        dayNotices: {
            type: new GraphQLList(NoticeType),
            args: {submissionDate: {type: GQDate}},
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {submissionDate: args.submissionDate});
            }
        },
        weekNotices: {
            type: new GraphQLList(NoticeType),
            args: {weekNumber: {type:GraphQLInt}},
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {week: args.weekNumber});
            }
        },
        // idk how the GQDate can be used or it's point 😅
        // this seems more simple and elegant imo
        monthNotices: {
            type: new GraphQLList(NoticeType),
            args: {month: {type:GraphQLInt}},
            resolve(parent, args){
                // code to get data from source
                return _.filter(notices, {month: args.month});
            }
        },
        GQDate     
    }
})

module.exports = new GraphQLSchema({
    query: RootQuery
})