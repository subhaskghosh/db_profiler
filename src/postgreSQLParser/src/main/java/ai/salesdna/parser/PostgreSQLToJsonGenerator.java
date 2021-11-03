package ai.salesdna.parser;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNodeImpl;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Given a SQL file generates a map of AST
 */

public class PostgreSQLToJsonGenerator {
    final String input;
    private static final Gson PRETTY_PRINT_GSON = new GsonBuilder().disableHtmlEscaping().setPrettyPrinting().create();
    private static final Gson PRINT_GSON = new GsonBuilder().disableHtmlEscaping().create();
    private static final Gson GSON = new Gson();

    public String toJson(ParseTree tree) {
        return toJson(tree, true);
    }

    public String toJson(ParseTree tree, boolean prettyPrint) {
        return prettyPrint ? PRETTY_PRINT_GSON.toJson(toMap(tree)) : GSON.toJson(toMap(tree));
    }

    public String toJson(Map<String, Object> map) {
        return PRETTY_PRINT_GSON.toJson(map);
    }


    public Map<String, Object> toMap(ParseTree tree) {
        Map<String, Object> map = new LinkedHashMap<>();
        traverse(tree, map);
        return map;
    }

    public void traverse(ParseTree tree, Map<String, Object> map) {

        if (tree instanceof TerminalNodeImpl) {
            Token token = ((TerminalNodeImpl) tree).getSymbol();
            map.put("line", token.getLine());
            map.put("type", token.getType());
            map.put("text", token.getText());
            map.put("cpos", token.getCharPositionInLine());
        }
        else {
            List<Map<String, Object>> children = new ArrayList<>();
            String name = tree.getClass().getSimpleName().replaceAll("Context$", "");
            map.put(Character.toLowerCase(name.charAt(0)) + name.substring(1), children);

            for (int i = 0; i < tree.getChildCount(); i++) {
                Map<String, Object> nested = new LinkedHashMap<>();
                children.add(nested);
                traverse(tree.getChild(i), nested);
            }
        }
    }

    public PostgreSQLToJsonGenerator(String input){
        this.input = input;
    }

    public Map<String, Object> getJson() {
        File file = new File(this.input);

        try {
            // Open the input file stream
            FileInputStream fis = new FileInputStream(file);
            // create a CharStream that reads from standard input
            CharStream mainStream = new ANTLRInputStream(fis);
            final CharStream input = new CaseChangingCharStream(mainStream, true);
            // create a lexer that feeds off of input CharStream
            ai.salesdna.parser.SQLLexer lexer = new ai.salesdna.parser.SQLLexer(input);
            // create a buffer of tokens pulled from the lexer
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            // create a parser that feeds off the tokens buffer
            ai.salesdna.parser.SQLParser parser = new ai.salesdna.parser.SQLParser(tokens);
            ParseTree tree = parser.sql(); // begin parsing at init rule
            Map<String, Object> parseMap = toMap(tree);
            parseMap.put("file", file.getName());
            parseMap.put("query",input.getText(new Interval(0,input.size())));
            fis.close();
            return parseMap;
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }
}
