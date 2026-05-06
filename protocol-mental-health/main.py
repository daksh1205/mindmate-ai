from langchain_community.document_loaders import PyPDFLoader, DirectoryLoader
from langchain_community.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_google_genai import ChatGoogleGenerativeAI, HarmBlockThreshold, HarmCategory
from langchain.chains import RetrievalQA
from fastapi import FastAPI
from pydantic import BaseModel
import tiktoken
import uvicorn
import os
from dotenv import load_dotenv

load_dotenv()

# --- Tokenizer ---
def tiktoken_len(text):
    tokenizer = tiktoken.get_encoding("cl100k_base")
    tokens = tokenizer.encode(text, disallowed_special=())
    return len(tokens)


# --- Build or load the vector store ---
def load_vectorstore():
    index_path = "mindmate_faiss_index"
    embeddings = OpenAIEmbeddings()

    if os.path.exists(index_path):
        return FAISS.load_local(
            index_path, embeddings, allow_dangerous_deserialization=True
        )

    loader = PyPDFLoader("resources/Anxiety-Help-Book-For-Teens.pdf")
    docs = loader.load()

    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=300,        # larger chunks = more context per retrieval
        chunk_overlap=50,
        length_function=tiktoken_len,
        separators=["\n\n", "\n"],
    )
    split_docs = text_splitter.split_documents(docs)

    vectorstore = FAISS.from_documents(split_docs, embeddings)
    vectorstore.save_local(index_path)
    return vectorstore


# --- Build the QA chain ---
def build_qa_chain(vectorstore):
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash",
        temperature=0.7,
        max_output_tokens=300,   # keep responses short like MindMate's style
        safety_settings={
            HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
        },
    )

    return RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    )


# --- System prompt (mirrors MindMate's personality) ---
SYSTEM_PROMPT = """You are MindMate, a warm and empathetic AI companion for teenagers aged 13-19.

Rules:
- Keep responses to 1-2 short sentences MAX, like a friend texting.
- Never write paragraphs or bullet points.
- Validate feelings first, advise only if asked.
- Use at most 1 emoji per message, only when natural.
- Never diagnose or act as a therapist.
- If the user seems in crisis, gently encourage them to call a helpline.
- Use the retrieved context to inform your response, but don't quote it directly.

User message: """


# --- FastAPI server so Flutter can call this as a backend ---
app = FastAPI()
vectorstore = load_vectorstore()
qa_chain = build_qa_chain(vectorstore)


class MessageRequest(BaseModel):
    message: str


class MessageResponse(BaseModel):
    response: str


@app.post("/chat", response_model=MessageResponse)
async def chat(req: MessageRequest):
    prompt = SYSTEM_PROMPT + req.message
    result = qa_chain.invoke({"query": prompt})
    return MessageResponse(response=result["result"])


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)