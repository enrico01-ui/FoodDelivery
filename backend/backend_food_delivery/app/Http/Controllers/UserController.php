<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Profil;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class UserController extends Controller
{
    
    public function index()
    {
        $user = User::all();
        return response()->json($user);
    }

    public function register(Request $request)
    {
        $request->validate(
            [
                'name' => 'required|string',
                'email' => 'required|string',
                'password' => 'required|string',
                'image' => 'nullable|string',
                'address' => 'required|string',
            ]
        );

        $find = User::where('email', $request->email)->first();
        if ($find) {
            return response()->json(['message' => 'Account Already Exist!'], 401);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $profildata = [
            'email' => $request->email,  // User email
            'bio' => 'Hello, I am a new user',  // Use provided bio or default if empty
            'image' => $this->getGravatarUrl($request->email),
            'address' => $request->address,
        ];


        $profil = Profil::create($profildata);

        return response()->json([
            'user' => $user,
            'profil' => $profil,
            'message' => 'User created successfully'
        ], 200);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        //with profil data

        $user = User::with('profil')->where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'email Not Found'], 401);
        }

        if(!Hash::check($request->password, $user->password)){
            return response()->json(['message' => 'Invalid Credentials'], 401);
        }

        $token = $user->createToken('Personal Access Token')->plainTextToken;

        $rememberToken = null;

        return response()->json(['detail' => $user, 'token' => $token, 'remember_token' => $rememberToken,'message' => 'Logged In']);
    }

    public function getGravatarUrl($email)
    {
        $emailHash = md5(strtolower(trim($email)));
        return 'https://www.gravatar.com/avatar/' . $emailHash . '?d=identicon';  // Default to 'identicon' if no Gravatar
    }

    public function logout(Request $request)
    {
        if (Auth::check()) {
            $request->user()->currentAccessToken()->delete();
            $request->user()->remember_token = null;
            $request->user()->save();

            return response()->json(['message' => 'Logged Out Successfully']);
        }

        return response()->json(['message' => 'Not Logged In'], 401);
    }

    //update adress
    public function updateAddress(Request $request)
    {
        $request->validate([
            'address' => 'required|string',
        ]);

        $profil = Profil::where('email', Auth::user()->email)->first();

        if (!$profil) {
            return response()->json(['message' => 'Profil not found'], 404);
        }

        $profil->update([
            'address' => $request->address,
        ]);

        return response()->json(['message' => 'Profil updated successfully', 'profil' => $profil], 200);
    }

    public function update(Request $request)
    {
        $request->validate([
            'name' => 'nullable|string|max:255|unique:users,name,' . Auth::id(),//kayanya auth buat cek biar ga duplikat//kayanya auth buat cek biar ga duplikat
            'password' => 'required|string',
            'new_password' => 'nullable|string|min:8'
        ]);

        $userid = Auth::id();
        $user = User::find($userid);

        if (!Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Incorrect password'], 403);
        }

        if ($request->filled('new_password')) {
            $user->password = Hash::make($request->new_password);
        }

        $dataToUpdate = [];
        if ($request->filled('name')) {
            $dataToUpdate['name'] = $request->name;
        }

        $user->update($dataToUpdate);

        return response()->json(['message' => 'User updated successfully', 'user' => $user], 200);
    }

    public function destroy(Request $request)
    {
        $request->validate([
            'password' => 'required|string'
        ]);

        if (!Hash::check($request->password, Auth::user()->password)) {
            return response()->json(['message' => 'Incorrect password'], 403);
        }

        $user = Auth::user();

        DB::transaction(function () use ($user) {
            $user->tokens()->delete();
            $user->delete();
        });

        return response()->json(['message' => 'User is deleted successfully'], 200);
    }

    public function getDataUser(Request $request){
        $request->validate([
            'name' => 'required|string'
        ]);

        $user = User::where('name', $request->name)->first();

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json(['email' => $user->email,'noTelp' => $user->noTelp ,'message' => 'Email found']);
    }
}
