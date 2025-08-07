<?php

namespace App\Http\Controllers;
use App\Models\Profil;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Http\Request;

class ProfilController extends Controller
{
    public function index()
    {
        $profil = Profil::all();
        return response()->json($profil);
    }

    public function show(Request $request)
{

    $validatedData = $request->validate([
        'email' => 'required|email'
    ]);

    $profile = Profil::with('user')->where('email', $validatedData['email'])->first();

    if ($profile) {
        return response()->json($profile, 200);  // Success
    }

    return response()->json([
        'message' => 'Profile not found'
    ], 404);  
}


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request)
    {
        $validatedData = $request->validate([
            'email' => 'required|email',
            'bio' => 'nullable|string',
            'image' => 'nullable|string',
            'address' => 'required|string'
        ]);

        $profil = Profil::where('email', $validatedData['email'])->first();

        if($profil) {
            if($request->filled('bio')) {
                $profil->bio = $validatedData['bio'];
                $profil->save();
            }
            if($request->filled('image')) {
                $profil->image = $validatedData['image'];
                $profil->save();
            }
            return response()->json([
                'message' => 'Profil updated successfully',
                'profil' => $profil
            ]);
        } else {
            return response()->json([
                'message' => 'Profil not found'
            ], 403);
        }


    }


    public function destroy(Profil $profil)
    {
        //
    }
}
