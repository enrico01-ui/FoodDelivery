<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Restaurant;

class RestaurantController extends Controller
{
    public function index()
    {
        $restaurants = Restaurant::all();
        return response()->json($restaurants->map(function ($restaurant) {
            return [
                'id' => $restaurant->id,
                'name' => $restaurant->name,
                'address' => $restaurant->address,
                'phone_number' => $restaurant->phone_number,
                'description' => $restaurant->description,
                'logo_url' => $restaurant->logo_url ?? '', // Default jika null
                'rating' => $restaurant->rating ?? 0,
                'open_time' => $restaurant->open_time ?? '00:00',
                'close_time' => $restaurant->close_time ?? '00:00',
            ];
        }));
    }

    public function store(Request $request)
    {
        $request->validate(
            [
                'name' => 'required|string',
                'address' => 'required|string',
                'phone_number' => 'required|string',
                'rating' => 'required|numeric',
                'logo_url' => 'required|string',
                'open_time' => 'required|string',
                'close_time' => 'required|string',
            ]
        );

        $restaurant = Restaurant::create([
            'name' => $request->name,
            'address' => $request->address,
            'phone_number' => $request->phone_number,
            'rating' => $request->rating,
            'logo_url' => $request->logo_url,
            'open_time' => $request->open_time,
            'close_time' => $request->close_time,
        ]);

        return response()->json([
            'message' => 'Restaurant Created Successfully',
            'data' => $restaurant
        ]);
    }

    public function show(Request $request)
    {
        $request->validate(
            [
                'name' => 'required|string',
                'address' => 'required|string',
            ]
        );

        $restaurant = Restaurant::where('name', 'like', '%' . $request->name . '%')
                        ->where('address', 'like', '%' . $request->address . '%')
                        ->get();
        
        if($restaurant->count() > 0) {
            return response()->json([
                'message' => 'Pemesanan found',
                'data' => $restaurant
            ], 200);
        } else {
            return response()->json([
                'message' => 'Pemesanan not found'
            ], status: 403);
        }
        
    }

    public function destroy(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
        ]);

        $restaurant = pemesanan::where('name', 'like', '%' . $request->name . '%')->first();

        if($restaurant->count() > 0) {
            $restaurant->delete();
            return response()->json([
                'message' => 'Pemesanan deleted successfully'
            ], 200);
        } else {
            return response()->json([
                'message' => 'Pemesanan not found'
            ], 404);
        }
    }
}
